extends Node
class_name GameRuntime

signal status_updated
signal event_opened(event: EventDefinition)
signal combat_opened
signal game_over(message: String)
signal arrival_completed(planet_id: StringName)

const SETUP_PATH := "res://data/game_setup.tres"
const MANUAL_SAVE_SLOTS := 3
const EVENT_INTERVAL_SECONDS := 60.0

var catalog := ContentCatalog.new()
var setup: GameSetupDefinition
var session := GameSession.new()
var inventory := InventoryModel.new()
var combat := CombatEncounter.new()
var is_configured := false
var gameplay_active := false
var setup_status := "Loading game content…"
var _event_clock := 0.0
var active_mission_id: StringName
var mission_completed := false
var mission_failed := false
var credits := 0
var reputation_xp := 0
var galaxy_markers: Dictionary = {}
var _market_instance_counter := 0
var _playtime_seconds := 0.0
var civilization_failures: Dictionary = {}
var blocked_civilizations: Dictionary = {}
var _combat_damage_clock := 0.0
var _starting_item_templates: Array[ItemInstance] = []


func _ready() -> void:
	catalog.load_all()
	setup = DemoContent.install(catalog)
	var using_demo_setup := true
	if ResourceLoader.exists(SETUP_PATH):
		var configured_setup := ResourceLoader.load(SETUP_PATH) as GameSetupDefinition
		if configured_setup != null:
			setup = configured_setup
			using_demo_setup = false
	if setup == null:
		setup_status = "Game setup data is missing."
		status_updated.emit()
		return
	if not setup.is_valid_definition(catalog):
		setup_status = "Game setup needs a starting planet, ship, food, and hull value."
		status_updated.emit()
		return
	_starting_item_templates.clear()
	for source_item in setup.starting_items:
		if source_item != null:
			_starting_item_templates.append(source_item.duplicate(true) as ItemInstance)
	var ship := catalog.get_definition("ship", setup.starting_ship_id) as ShipDefinition
	inventory.configure(ship)
	for starting_item in setup.starting_items:
		if starting_item == null:
			setup_status = "Game setup contains an empty starting item."
			status_updated.emit()
			return
		var placement := inventory.try_place(starting_item, starting_item.grid_position, starting_item.rotation_quarters)
		if not placement.valid:
			setup_status = "Starting item placement is invalid: %s" % placement.reason
			status_updated.emit()
			return
	_recalculate_equipment_bonuses()
	session.configure(setup.starting_planet_id, setup.starting_resource_values, setup.starting_hull_hp, {}, Callable(self, "_resolve_content"))
	_recalculate_equipment_bonuses()
	active_mission_id = setup.starting_mission_id
	credits = setup.starting_credits
	session.state_changed.connect(_on_state_changed)
	session.event_requested.connect(_on_event_requested)
	session.combat_requested.connect(_on_combat_requested)
	session.arrived.connect(_on_arrived)
	session.died.connect(_on_died)
	combat.resolved.connect(_on_combat_resolved)
	combat.started.connect(_on_combat_started)
	var loaded_existing_save := false
	var load_path := GameSession.AUTOSAVE_PATH
	if not FileAccess.file_exists(load_path) and FileAccess.file_exists(GameSession.LEGACY_SAVE_PATH):
		load_path = GameSession.LEGACY_SAVE_PATH
	elif not FileAccess.file_exists(load_path):
		var newest_slot := 0
		var newest_timestamp := ""
		for slot_index in range(1, MANUAL_SAVE_SLOTS + 1):
			var slot_info := get_save_slot_info(slot_index)
			if slot_info.exists and String(slot_info.saved_at) > newest_timestamp:
				newest_timestamp = String(slot_info.saved_at)
				newest_slot = slot_index
		if newest_slot > 0:
			load_path = _manual_slot_path(newest_slot)
	if FileAccess.file_exists(load_path):
		var load_result := session.load_game(load_path)
		if load_result.ok:
			var inventory_result := _restore_inventory()
			if inventory_result.ok:
				var campaign_result := _restore_campaign_state()
				if campaign_result.ok:
					loaded_existing_save = true
				else:
					_reset_runtime_state()
					setup_status = "Official demo setup"
			else:
				# A save from the pre-official ship grid may load as JSON but still
				# contain placements that cannot exist on the current ship. Ignore it
				# for boot, then provide a clean New Game state.
				_reset_runtime_state()
				setup_status = "Official demo setup"
		else:
			# Old demo saves can contain placements outside the official ship grid.
			# Keep the file for manual recovery, but start from a clean official state.
			_reset_runtime_state()
			setup_status = "Official demo setup"
	if not loaded_existing_save:
		_reset_runtime_state()
	elif load_path != GameSession.AUTOSAVE_PATH:
		_save_autosave()
	setup_status = "%s · %s" % ["Demo scenario" if using_demo_setup else "Ready", ship.display_name]
	is_configured = true
	status_updated.emit()


func _process(delta: float) -> void:
	if not is_configured or not gameplay_active:
		return
	_playtime_seconds += maxf(delta, 0.0)
	if session.state == GameSession.TravelState.TRAVELLING:
		combat.tick(delta)
		if combat.active:
			_combat_damage_clock += maxf(delta, 0.0)
			if _combat_damage_clock >= 10.0:
				_combat_damage_clock = 0.0
				session.apply_hull_damage(1.0)
		var food_before := float(session.resources.get("food", 0.0))
		session.tick_travel(delta)
		_apply_food_conversion(food_before)
		if not combat.active and session.state == GameSession.TravelState.TRAVELLING:
			_event_clock += maxf(delta, 0.0)
			if _event_clock >= EVENT_INTERVAL_SECONDS:
				_event_clock = 0.0
				_request_timed_event()
	elif session.state == GameSession.TravelState.STRANDED:
		session.tick_travel(delta)


func begin_travel(travel_id: StringName) -> Dictionary:
	if not is_configured:
		return _failure(setup_status)
	var definition := catalog.get_definition("travel", travel_id) as TravelDefinition
	if definition != null:
		var destination := catalog.get_definition("planet", definition.destination_planet_id) as PlanetDefinition
		if destination == null or not destination.is_valid_definition():
			return _failure("Travel destination planet data is missing.")
	var quote := get_travel_quote(travel_id)
	if not quote.ok:
		return quote
	_save_autosave()
	var result := session.begin_travel(definition)
	_event_clock = 0.0
	status_updated.emit()
	return result


func get_travel_quote(travel_id: StringName) -> Dictionary:
	var definition := catalog.get_definition("travel", travel_id) as TravelDefinition
	if definition == null or not definition.is_valid_definition():
		return _failure("Travel data is incomplete.")
	if definition.origin_planet_id != session.current_planet_id:
		return _failure("Travel origin does not match the current planet.")
	var seconds := 0.0
	for segment_duration in definition.segment_durations_seconds:
		seconds += segment_duration
	var cost := {}
	for resource_id in definition.resource_drain_per_second:
		cost[resource_id] = float(definition.resource_drain_per_second[resource_id]) * seconds
	for segment_index in definition.segment_events:
		var event: EventDefinition = definition.segment_events[segment_index]
		var worst_delta := {}
		for effect in event.choice_effects:
			for resource_id in effect.get("resource_delta", {}):
				var delta := float(effect.resource_delta[resource_id])
				worst_delta[resource_id] = minf(float(worst_delta.get(resource_id, 0.0)), delta)
		for resource_id in worst_delta:
			cost[resource_id] = float(cost.get(resource_id, 0.0)) + absf(minf(0.0, float(worst_delta[resource_id])))
	var food_needed := float(cost.get("food", 0.0))
	var fuel_needed := float(cost.get("fuel", 0.0))
	var food_available := float(session.resources.get("food", 0.0))
	var fuel_available := float(session.resources.get("fuel", 0.0))
	var can_afford := food_available + 0.0001 >= food_needed and fuel_available + 0.0001 >= fuel_needed
	return {
		"ok": can_afford,
		"reason": "Not enough food for this journey." if food_available + 0.0001 < food_needed else "Not enough fuel for this journey." if fuel_available + 0.0001 < fuel_needed else "",
		"travel_id": travel_id,
		"duration_seconds": seconds,
		"food_cost": food_needed,
		"fuel_cost": fuel_needed,
		"food_available": food_available,
		"fuel_available": fuel_available,
		"costs": cost,
	}


func set_galaxy_marker(system_id: String, marker_id: int) -> void:
	if marker_id < 0:
		galaxy_markers.erase(system_id)
	else:
		galaxy_markers[system_id] = marker_id


func choose_event(choice_index: int) -> Dictionary:
	var result := session.choose_event(choice_index)
	status_updated.emit()
	return result


func _request_timed_event() -> void:
	if session.pending_event != null or combat.active:
		return
	var event := catalog.get_definition("event", &"demo_supply_question") as EventDefinition
	if event == null:
		return
	session.pending_event = event
	session.state = GameSession.TravelState.EVENT_PAUSED
	session.state_changed.emit()
	event_opened.emit(event)


func _has_equipment_effect(effect_type: StringName) -> bool:
	for instance in inventory.items:
		if instance == null or instance.definition == null:
			continue
		for effect in instance.definition.effects:
			if StringName(effect.get("effect_type", "")) == effect_type:
				return true
	return false


func _recalculate_equipment_bonuses() -> void:
	if session == null:
		return
	session.max_resources = {"food": 100.0, "fuel": 100.0}
	var armor_max := 3.0
	for instance in inventory.items:
		if instance == null or instance.definition == null:
			continue
		for effect in instance.definition.effects:
			var kind := StringName(effect.get("effect_type", ""))
			if kind == &"maximum_resource":
				var resource_id := String(effect.get("resource", ""))
				session.max_resources[resource_id] = float(session.max_resources.get(resource_id, 100.0)) + float(effect.get("amount", 0.0))
			elif kind == &"maximum_armor":
				armor_max += float(effect.get("amount", 0.0))
	session.defense_pool = minf(session.defense_pool, armor_max) if session.defense_pool > 0.0 else armor_max
	for resource_id in session.max_resources:
		session.resources[resource_id] = minf(float(session.resources.get(resource_id, 0.0)), float(session.max_resources[resource_id]))


func _apply_food_conversion(food_before: float) -> void:
	var consumed := maxf(0.0, food_before - float(session.resources.get("food", 0.0)))
	if consumed <= 0.0:
		return
	for instance in inventory.items:
		if instance == null or instance.definition == null:
			continue
		for effect in instance.definition.effects:
			if StringName(effect.get("effect_type", "")) != &"food_to_fuel":
				continue
			var progress := float(instance.current_state.get("food_conversion_progress", 0.0)) + consumed
			var threshold := float(effect.get("food_per_trigger", 5.0))
			var triggers := floori(progress / threshold)
			if triggers > 0:
				var cap := float(session.max_resources.get("fuel", 100.0))
				session.resources["fuel"] = minf(cap, float(session.resources.get("fuel", 0.0)) + triggers * float(effect.get("fuel_per_trigger", 2.0)))
				progress -= triggers * threshold
			instance.current_state["food_conversion_progress"] = progress


func _is_required_mission_cargo(item_id: StringName) -> bool:
	if mission_completed or mission_failed or active_mission_id.is_empty():
		return false
	var mission := catalog.get_definition("mission", active_mission_id) as MissionDefinition
	if mission == null:
		return false
	for requirement in mission.required_cargo:
		if StringName(requirement.get("definition_id", "")) == item_id:
			return true
	return false


func _fail_active_mission() -> void:
	if mission_completed or mission_failed or active_mission_id.is_empty():
		return
	var planet := catalog.get_definition("planet", session.current_planet_id) as PlanetDefinition
	if planet != null and planet.civilization_present:
		var key := String(planet.system_id)
		civilization_failures[key] = int(civilization_failures.get(key, 0)) + 1
		if int(civilization_failures[key]) >= 5:
			blocked_civilizations[key] = "fine_due"
	mission_failed = true


func civilization_access_status() -> String:
	var planet := catalog.get_definition("planet", session.current_planet_id) as PlanetDefinition
	if planet == null:
		return ""
	return String(blocked_civilizations.get(String(planet.system_id), ""))


func pay_civilization_fine() -> Dictionary:
	if not _at_civilization_hub() or civilization_access_status() != "fine_due":
		return _failure("No civilization fine is due here.")
	if credits < 1000:
		return _failure("1,000 credits are required to clear this fine.")
	credits -= 1000
	var planet := catalog.get_definition("planet", session.current_planet_id) as PlanetDefinition
	blocked_civilizations.erase(String(planet.system_id))
	civilization_failures[String(planet.system_id)] = 0
	status_updated.emit()
	return {"ok": true, "reason": "Fine paid. Hub access restored."}


func refuse_civilization_fine() -> Dictionary:
	if not _at_civilization_hub() or civilization_access_status() != "fine_due":
		return _failure("No civilization fine is due here.")
	var planet := catalog.get_definition("planet", session.current_planet_id) as PlanetDefinition
	blocked_civilizations[String(planet.system_id)] = "blocked"
	status_updated.emit()
	return {"ok": true, "reason": "Access to this civilization is permanently blocked."}


func begin_combat(combat_id: StringName) -> Dictionary:
	if not is_configured or session.state != GameSession.TravelState.TRAVELLING:
		return _failure("Combat can only begin during travel.")
	var definition := catalog.get_definition("combat", combat_id) as CombatDefinition
	return combat.begin(definition)


func activate_special_equipment() -> Dictionary:
	if not _has_equipment_effect(&"absorb_projectile"):
		return _failure("ASECA is not installed.")
	return combat.activate_special_equipment()


func defeat_enemy() -> Dictionary:
	if not combat.active:
		return _failure("There is no active hostile target.")
	combat.enemy_defeated()
	return {"ok": true, "reason": "Target neutralized."}


func deliver_active_mission() -> Dictionary:
	if not is_configured or session.state != GameSession.TravelState.DOCKED:
		return _failure("Delivery can only be confirmed while docked.")
	if mission_completed or mission_failed or active_mission_id.is_empty():
		return _failure("There is no active delivery to complete.")
	var mission := catalog.get_definition("mission", active_mission_id) as MissionDefinition
	if mission == null or not mission.is_valid_definition():
		return _failure("Mission data is unavailable.")
	if mission.delivery_target_planet_id != session.current_planet_id:
		return _failure("This is not the delivery destination.")
	var required_counts: Dictionary = {}
	for requirement in mission.required_cargo:
		var item_id := StringName(requirement.get("definition_id", ""))
		var quantity := int(requirement.get("quantity", 0))
		if item_id.is_empty() or quantity <= 0:
			return _failure("Mission cargo requirements are incomplete.")
		required_counts[item_id] = int(required_counts.get(item_id, 0)) + quantity
	if required_counts.is_empty():
		return _failure("Mission has no cargo requirements.")
	for item_id in required_counts:
		var carried := 0
		for instance in inventory.items:
			if instance != null and not instance.delivered and instance.definition != null and instance.definition.id == item_id:
				carried += 1
		if carried < int(required_counts[item_id]):
			_fail_active_mission()
			return _failure("Required cargo is not aboard: %s." % item_id)
	for item_id in required_counts:
		var remaining := int(required_counts[item_id])
		for index in range(inventory.items.size() - 1, -1, -1):
			var instance := inventory.items[index]
			if remaining > 0 and instance != null and not instance.delivered and instance.definition != null and instance.definition.id == item_id:
				inventory.items.remove_at(index)
				remaining -= 1
	credits += int(mission.reward_data.get("credits", 0))
	reputation_xp += int(mission.reward_data.get("reputation_xp", 0))
	mission_completed = true
	_sync_inventory_save_data()
	status_updated.emit()
	return {"ok": true, "reason": "Delivery completed."}


func buy_market_item(item_id: StringName) -> Dictionary:
	if not _at_civilization_hub():
		return _failure("Shopping is only available at a civilization hub.")
	var planet := catalog.get_definition("planet", session.current_planet_id) as PlanetDefinition
	if not planet.market_item_ids.has(item_id):
		return _failure("This item is not stocked at the current hub.")
	var definition := catalog.get_definition("item", item_id) as ItemDefinition
	if definition == null or not definition.is_valid_definition() or definition.buy_price < 0:
		return _failure("This item has no configured buy price.")
	if credits < definition.buy_price:
		return _failure("Not enough credits.")
	var instance := ItemInstance.new()
	_market_instance_counter += 1
	instance.instance_id = StringName("market_%s_%d" % [definition.id, _market_instance_counter])
	instance.definition = definition
	instance.durability_current = definition.maximum_durability if definition.has_durability else -1
	for cell in inventory.ship.valid_grid_cells:
		for rotation in 4:
			var placed := inventory.try_place(instance, cell, rotation)
			if placed.valid:
				credits -= definition.buy_price
				_recalculate_equipment_bonuses()
				_sync_inventory_save_data()
				status_updated.emit()
				return {"ok": true, "reason": "Item purchased and placed in the ship grid."}
	return _failure("There is no valid space for this item.")


func sell_inventory_item(instance_id: StringName) -> Dictionary:
	if not _at_civilization_hub():
		return _failure("Trading is only available at a civilization hub.")
	for instance in inventory.items:
		if instance == null or instance.delivered or instance.instance_id != instance_id or instance.definition == null:
			continue
		if instance.definition.sell_price < 0:
			return _failure("This item cannot be sold here.")
		if _is_required_mission_cargo(instance.definition.id):
			_fail_active_mission()
		credits += instance.definition.sell_price
		reputation_xp = maxi(0, reputation_xp + instance.definition.sell_reputation_delta)
		inventory.remove_item(instance)
		_recalculate_equipment_bonuses()
		_sync_inventory_save_data()
		status_updated.emit()
		return {"ok": true, "reason": "Item sold."}
	return _failure("Item is no longer aboard the ship.")


func _at_civilization_hub() -> bool:
	if not is_configured or session.state != GameSession.TravelState.DOCKED:
		return false
	var planet := catalog.get_definition("planet", session.current_planet_id) as PlanetDefinition
	return planet != null and planet.civilization_present and civilization_access_status() != "blocked"


func try_place_item(instance: ItemInstance, anchor: Vector2i, rotation_quarters: int) -> Dictionary:
	if not is_configured:
		return _failure(setup_status)
	var travelling := session.state != GameSession.TravelState.DOCKED or combat.active
	if not inventory.can_rearrange(travelling):
		return _failure("Inventory cannot be rearranged while travelling.")
	var result := inventory.try_place(instance, anchor, rotation_quarters)
	if result.valid:
		status_updated.emit()
	return result


func save_game(slot_index: int = 1) -> Dictionary:
	if not is_configured:
		return _failure(setup_status)
	if slot_index < 1 or slot_index > MANUAL_SAVE_SLOTS:
		return _failure("Choose a valid manual save slot.")
	if session.state != GameSession.TravelState.DOCKED:
		return _failure("Manual saves are only available while docked.")
	_prepare_save("Save Slot %d" % slot_index)
	var saved := session.save_game(_manual_slot_path(slot_index), _manual_previous_path(slot_index))
	return {"ok": saved, "reason": "" if saved else "Save could not be written."}


func save_autosave() -> Dictionary:
	if not is_configured:
		return _failure(setup_status)
	var saved := _save_autosave()
	return {"ok": saved, "reason": "" if saved else "Autosave could not be written."}


func load_game(slot_index: int = 1) -> Dictionary:
	if slot_index < 1 or slot_index > MANUAL_SAVE_SLOTS:
		return _failure("Choose a valid manual save slot.")
	return _load_game_path(_manual_slot_path(slot_index))


func load_autosave() -> Dictionary:
	return _load_game_path(GameSession.AUTOSAVE_PATH)


func continue_game() -> Dictionary:
	if FileAccess.file_exists(GameSession.AUTOSAVE_PATH):
		return load_autosave()
	var newest_slot := 0
	var newest_timestamp := ""
	for slot_index in range(1, MANUAL_SAVE_SLOTS + 1):
		var info := get_save_slot_info(slot_index)
		if info.exists and String(info.saved_at) > newest_timestamp:
			newest_timestamp = String(info.saved_at)
			newest_slot = slot_index
	if newest_slot > 0:
		return load_game(newest_slot)
	return _failure("No saved game is available.")


func start_new_game() -> Dictionary:
	if not is_configured:
		return _failure(setup_status)
	_reset_runtime_state()
	status_updated.emit()
	return {"ok": true, "reason": "New demo game started."}


func get_save_slot_info(slot_index: int) -> Dictionary:
	var path := GameSession.AUTOSAVE_PATH if slot_index == 0 else _manual_slot_path(slot_index)
	var title := "Autosave" if slot_index == 0 else "Save Slot %d" % slot_index
	if slot_index < 0 or slot_index > MANUAL_SAVE_SLOTS or not FileAccess.file_exists(path):
		return {"exists": false, "title": title, "saved_at": "", "planet_id": "", "credits": 0, "mission_completed": false}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false, "title": title, "saved_at": "", "planet_id": "", "credits": 0, "mission_completed": false}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"exists": false, "title": title, "saved_at": "", "planet_id": "", "credits": 0, "mission_completed": false}
	return {
		"exists": true,
		"title": String(parsed.get("slot_label", title)),
		"saved_at": String(parsed.get("saved_at", "Unknown time")),
		"planet_id": String(parsed.get("current_planet_id", "")),
		"credits": int(parsed.get("credits", 0)),
		"mission_completed": bool(parsed.get("mission_completed", false)),
		"playtime_seconds": float(parsed.get("playtime_seconds", 0.0)),
	}


func delete_save_slot(slot_index: int) -> Dictionary:
	if slot_index < 1 or slot_index > MANUAL_SAVE_SLOTS:
		return _failure("Only manual save slots can be deleted here.")
	var path := _manual_slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return _failure("This save slot is already empty.")
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if error != OK:
		return _failure("Save file could not be deleted.")
	var previous_path := _manual_previous_path(slot_index)
	if FileAccess.file_exists(previous_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(previous_path))
	return {"ok": true, "reason": "Save slot deleted."}


func _load_game_path(path: String) -> Dictionary:
	if not is_configured:
		return _failure(setup_status)
	if not FileAccess.file_exists(path):
		return _failure("This save slot is empty.")
	var result := session.load_game(path)
	if not result.ok:
		return result
	var inventory_result := _restore_inventory()
	if not inventory_result.ok:
		return inventory_result
	var campaign_result := _restore_campaign_state()
	if not campaign_result.ok:
		return campaign_result
	_playtime_seconds = float(session._save_payload.get("playtime_seconds", 0.0))
	_event_clock = 0.0
	combat.active = false
	combat.definition = null
	combat.elapsed_seconds = 0.0
	combat.enemies_remaining = 0
	status_updated.emit()
	if session.pending_event != null:
		event_opened.emit(session.pending_event)
	return {"ok": true, "reason": ""}


func _prepare_save(slot_label: String) -> void:
	_sync_inventory_save_data()
	session._save_payload["slot_label"] = slot_label
	session._save_payload["saved_at"] = Time.get_datetime_string_from_system()
	session._save_payload["playtime_seconds"] = _playtime_seconds
	session._save_payload["galaxy_markers"] = galaxy_markers.duplicate(true)
	session._save_payload["civilization_failures"] = civilization_failures.duplicate(true)
	session._save_payload["blocked_civilizations"] = blocked_civilizations.duplicate(true)



func _save_autosave() -> bool:
	_prepare_save("Autosave")
	return session.save_game(GameSession.AUTOSAVE_PATH)


func _manual_slot_path(slot_index: int) -> String:
	return "user://space_courier_slot_%d.json" % slot_index


func _manual_previous_path(slot_index: int) -> String:
	return "user://space_courier_slot_%d_previous.json" % slot_index


func _reset_runtime_state() -> void:
	var ship := catalog.get_definition("ship", setup.starting_ship_id) as ShipDefinition
	inventory.configure(ship)
	for starting_item in _starting_item_templates:
		var fresh_item := starting_item.duplicate(true) as ItemInstance
		inventory.try_place(fresh_item, fresh_item.grid_position, fresh_item.rotation_quarters)
	session.configure(setup.starting_planet_id, setup.starting_resource_values, setup.starting_hull_hp, {}, Callable(self, "_resolve_content"))
	active_mission_id = setup.starting_mission_id
	mission_completed = false
	mission_failed = false
	credits = setup.starting_credits
	reputation_xp = 0
	galaxy_markers.clear()
	civilization_failures.clear()
	blocked_civilizations.clear()
	_playtime_seconds = 0.0
	_event_clock = 0.0
	_market_instance_counter = 0
	combat.active = false
	combat.definition = null


func _resolve_content(category: String, definition_id: StringName) -> Resource:
	return catalog.get_definition(category, definition_id)


func _on_state_changed() -> void:
	status_updated.emit()


func _on_event_requested(event: EventDefinition) -> void:
	event_opened.emit(event)


func _on_combat_requested(combat_id: StringName) -> void:
	var result := begin_combat(combat_id)
	if not result.ok:
		push_warning(result.reason)


func _on_combat_started() -> void:
	_combat_damage_clock = 0.0
	combat_opened.emit()


func _on_arrived(planet_id: StringName) -> void:
	arrival_completed.emit(planet_id)


func _on_combat_resolved(_won_by: StringName) -> void:
	_combat_damage_clock = 0.0
	status_updated.emit()


func _on_died() -> void:
	game_over.emit("Ship lost. Choose New Game, Load Latest Save, or Load Save.")
	status_updated.emit()


func _sync_inventory_save_data() -> void:
	var saved_items: Array[Dictionary] = []
	for index in inventory.items.size():
		var instance := inventory.items[index]
		if instance == null or instance.definition == null:
			continue
		if instance.instance_id.is_empty():
			instance.instance_id = StringName("%s_%d" % [instance.definition.id, index])
		saved_items.append({
			"instance_id": String(instance.instance_id),
			"definition_id": String(instance.definition.id),
			"grid_position": [instance.grid_position.x, instance.grid_position.y],
			"rotation_quarters": instance.rotation_quarters,
			"current_state": instance.current_state.duplicate(true),
			"durability_current": instance.durability_current,
			"delivered": instance.delivered,
		})
	session._save_payload["items"] = saved_items
	session._save_payload["defense_pool"] = session.defense_pool
	session._save_payload["credits"] = credits
	session._save_payload["reputation_xp"] = reputation_xp
	session._save_payload["active_mission_id"] = String(active_mission_id)
	session._save_payload["mission_completed"] = mission_completed
	session._save_payload["mission_failed"] = mission_failed


func _restore_inventory() -> Dictionary:
	var restored_inventory := InventoryModel.new()
	restored_inventory.configure(inventory.ship)
	for saved_item in session._save_payload.get("items", []):
		if typeof(saved_item) != TYPE_DICTIONARY:
			return _failure("Saved item data is invalid.")
		var item_definition := catalog.get_definition("item", StringName(saved_item.get("definition_id", ""))) as ItemDefinition
		if item_definition == null or not item_definition.is_valid_definition():
			return _failure("Saved item definition is unavailable.")
		var instance := ItemInstance.new()
		instance.instance_id = StringName(saved_item.get("instance_id", ""))
		if instance.instance_id.is_empty():
			return _failure("Saved item instance id is missing.")
		instance.definition = item_definition
		var position: Variant = saved_item.get("grid_position", [0, 0])
		if typeof(position) != TYPE_ARRAY or position.size() != 2:
			return _failure("Saved item position is invalid.")
		instance.grid_position = Vector2i(int(position[0]), int(position[1]))
		instance.rotation_quarters = posmod(int(saved_item.get("rotation_quarters", 0)), 4)
		var saved_state: Variant = saved_item.get("current_state", {})
		if typeof(saved_state) != TYPE_DICTIONARY:
			return _failure("Saved item state is invalid.")
		instance.current_state = saved_state.duplicate(true)
		instance.durability_current = int(saved_item.get("durability_current", -1))
		instance.delivered = bool(saved_item.get("delivered", false))
		if instance.delivered:
			restored_inventory.items.append(instance)
		else:
			var placed := restored_inventory.try_place(instance, instance.grid_position, instance.rotation_quarters)
			if not placed.valid:
				return _failure("Saved item placement is invalid: %s" % placed.reason)
	inventory.items = restored_inventory.items
	session.defense_pool = float(session._save_payload.get("defense_pool", 0.0))
	_recalculate_equipment_bonuses()
	return {"ok": true, "reason": ""}


func _restore_campaign_state() -> Dictionary:
	var loaded_mission_id := StringName(session._save_payload.get("active_mission_id", String(setup.starting_mission_id)))
	if not loaded_mission_id.is_empty() and catalog.get_definition("mission", loaded_mission_id) == null:
		return _failure("Saved mission definition is unavailable.")
	credits = int(session._save_payload.get("credits", setup.starting_credits))
	reputation_xp = int(session._save_payload.get("reputation_xp", 0))
	active_mission_id = loaded_mission_id
	mission_completed = bool(session._save_payload.get("mission_completed", false))
	mission_failed = bool(session._save_payload.get("mission_failed", false))
	var saved_markers: Variant = session._save_payload.get("galaxy_markers", {})
	if typeof(saved_markers) != TYPE_DICTIONARY:
		return _failure("Saved map marker data is invalid.")
	galaxy_markers = saved_markers.duplicate(true)
	var saved_failures: Variant = session._save_payload.get("civilization_failures", {})
	var saved_blocks: Variant = session._save_payload.get("blocked_civilizations", {})
	if typeof(saved_failures) != TYPE_DICTIONARY or typeof(saved_blocks) != TYPE_DICTIONARY:
		return _failure("Saved civilization access data is invalid.")
	civilization_failures = saved_failures.duplicate(true)
	blocked_civilizations = saved_blocks.duplicate(true)
	return {"ok": true, "reason": ""}


func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
