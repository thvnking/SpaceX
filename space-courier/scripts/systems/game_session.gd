extends RefCounted
class_name GameSession

## Runtime state and transitions. Content and tuning are supplied as Resources.
signal state_changed
signal event_requested(event: EventDefinition)
signal combat_requested(combat_id: StringName)
signal died
signal arrived(planet_id: StringName)

enum TravelState { DOCKED, TRAVELLING, EVENT_PAUSED, DEAD }

const AUTOSAVE_PATH := "user://space_courier_autosave.json"
const PREVIOUS_AUTOSAVE_PATH := "user://space_courier_previous_autosave.json"
const LEGACY_SAVE_PATH := "user://space_courier_save.json"
const AUTOSAVE_INTERVAL_SECONDS := 300.0

var state: TravelState = TravelState.DOCKED
var current_planet_id: StringName
var resources: Dictionary = {}
var hull_hp: float = -1.0
var defense_pool: float = 0.0
var travel: TravelDefinition
var travel_elapsed := 0.0
var travel_segment_index := 0
var pending_event: EventDefinition
var _autosave_elapsed := 0.0
var _save_payload: Dictionary = {}
var content_lookup: Callable


func configure(initial_planet_id: StringName, initial_resources: Dictionary, initial_hull_hp: float, save_payload: Dictionary = {}, resolver: Callable = Callable()) -> void:
	current_planet_id = initial_planet_id
	resources = initial_resources.duplicate(true)
	hull_hp = initial_hull_hp
	defense_pool = 0.0
	travel = null
	travel_elapsed = 0.0
	travel_segment_index = 0
	pending_event = null
	_autosave_elapsed = 0.0
	_save_payload = save_payload.duplicate(true)
	content_lookup = resolver
	state = TravelState.DOCKED
	state_changed.emit()


func begin_travel(definition: TravelDefinition) -> Dictionary:
	if state != TravelState.DOCKED:
		return _failure("Travel can only start while docked.")
	if definition == null or not definition.is_valid_definition():
		return _failure("Travel data is incomplete.")
	if definition.origin_planet_id != current_planet_id:
		return _failure("Travel origin does not match the current planet.")
	travel = definition
	travel_elapsed = 0.0
	travel_segment_index = 0
	state = TravelState.TRAVELLING
	state_changed.emit()
	return _success()


func tick_travel(delta: float) -> Dictionary:
	if state != TravelState.TRAVELLING or travel == null:
		return _failure("The ship is not travelling.")
	if delta < 0.0:
		return _failure("Elapsed time cannot be negative.")
	var remaining := delta
	while remaining > 0.0 and state == TravelState.TRAVELLING and travel != null:
		var duration_left := travel.segment_durations_seconds[travel_segment_index] - travel_elapsed
		var step := minf(remaining, duration_left)
		for resource_id in travel.resource_drain_per_second:
			var rate := float(travel.resource_drain_per_second[resource_id])
			resources[resource_id] = maxf(0.0, float(resources.get(resource_id, 0.0)) - rate * step)
		travel_elapsed += step
		remaining -= step
		var segment_finished := travel_elapsed >= travel.segment_durations_seconds[travel_segment_index]
		if float(resources.get("food", -1.0)) == 0.0:
			var last_segment := travel_segment_index == travel.segment_durations_seconds.size() - 1
			if segment_finished and last_segment and not travel.segment_events.has(travel_segment_index):
				travel_elapsed = 0.0
				_request_segment_combat()
				_advance_segment()
				if state == TravelState.DOCKED:
					return _success()
			return _handle_death("Food reached zero.")
		if segment_finished:
			travel_elapsed = 0.0
			if travel.segment_events.has(travel_segment_index):
				pending_event = travel.segment_events[travel_segment_index]
				state = TravelState.EVENT_PAUSED
				state_changed.emit()
				event_requested.emit(pending_event)
				return {"ok": true, "event": pending_event}
			_request_segment_combat()
			_advance_segment()
	return _success()


func choose_event(choice_index: int) -> Dictionary:
	if state != TravelState.EVENT_PAUSED or pending_event == null:
		return _failure("There is no event awaiting a choice.")
	if choice_index < 0 or choice_index >= 2 or pending_event.choice_effects.size() != 2:
		return _failure("Event choice data is incomplete.")
	var effects: Dictionary = pending_event.choice_effects[choice_index]
	for resource_id in effects.get("resource_delta", {}):
		resources[resource_id] = maxf(0.0, float(resources.get(resource_id, 0.0)) + float(effects.resource_delta[resource_id]))
	if float(resources.get("food", -1.0)) == 0.0:
		return _handle_death("Food reached zero.")
	pending_event = null
	_request_segment_combat()
	_advance_segment()
	if state == TravelState.DOCKED:
		return _success()
	state = TravelState.TRAVELLING
	state_changed.emit()
	return _success()


func apply_hull_damage(amount: float) -> Dictionary:
	if not is_finite(amount) or amount < 0.0:
		return _failure("Damage must be a finite non-negative value.")
	if hull_hp < 0:
		return _failure("Hull health is not configured.")
	var remaining_damage := amount
	defense_pool = maxf(0.0, defense_pool)
	var absorbed := minf(defense_pool, remaining_damage)
	defense_pool -= absorbed
	remaining_damage -= absorbed
	hull_hp = maxf(0.0, hull_hp - remaining_damage)
	state_changed.emit()
	if hull_hp == 0:
		return _handle_death("Hull integrity reached zero.")
	return _success()


func arrive_at_destination() -> void:
	if travel == null:
		return
	current_planet_id = travel.destination_planet_id
	travel = null
	travel_elapsed = 0.0
	state = TravelState.DOCKED
	state_changed.emit()
	arrived.emit(current_planet_id)


func _advance_segment() -> void:
	if travel == null:
		return
	travel_segment_index += 1
	if travel_segment_index >= travel.segment_durations_seconds.size():
		arrive_at_destination()


func _request_segment_combat() -> void:
	if travel == null or not travel.segment_combats.has(travel_segment_index):
		return
	combat_requested.emit(StringName(travel.segment_combats[travel_segment_index]))


func apply_planet_refill(planet: PlanetDefinition) -> Dictionary:
	if state != TravelState.DOCKED or planet == null or planet.id != current_planet_id:
		return _failure("Refill can only be applied at the current planet.")
	for resource_id in planet.resource_refill:
		resources[resource_id] = float(resources.get(resource_id, 0.0)) + float(planet.resource_refill[resource_id])
	state_changed.emit()
	return _success()


func process_autosave(delta: float) -> bool:
	_autosave_elapsed += maxf(delta, 0.0)
	if _autosave_elapsed < AUTOSAVE_INTERVAL_SECONDS:
		return false
	_autosave_elapsed = fmod(_autosave_elapsed, AUTOSAVE_INTERVAL_SECONDS)
	return save_game(AUTOSAVE_PATH, PREVIOUS_AUTOSAVE_PATH)


func save_game(path: String = AUTOSAVE_PATH, previous_path: String = PREVIOUS_AUTOSAVE_PATH) -> bool:
	if current_planet_id.is_empty() or state == TravelState.DEAD:
		return false
	var payload := _save_payload.duplicate(true)
	payload["current_planet_id"] = String(current_planet_id)
	payload["resources"] = resources.duplicate(true)
	payload["hull_hp"] = hull_hp
	payload["defense_pool"] = maxf(0.0, defense_pool)
	payload["state"] = TravelState.keys()[state]
	payload["travel_id"] = String(travel.id) if travel != null else ""
	payload["travel_elapsed"] = travel_elapsed
	payload["travel_segment_index"] = travel_segment_index
	payload["pending_event_id"] = String(pending_event.id) if pending_event != null else ""
	if FileAccess.file_exists(path):
		var old_file := FileAccess.open(path, FileAccess.READ)
		if old_file != null:
			var old_text := old_file.get_as_text()
			old_file.close()
			var old_data: Variant = JSON.parse_string(old_text)
			if old_data is Dictionary:
				var backup := FileAccess.open(previous_path, FileAccess.WRITE)
				if backup == null:
					return false
				backup.store_string(JSON.stringify(old_data))
				backup.close()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload))
	file.close()
	_save_payload = payload
	return true


func load_game(path: String = AUTOSAVE_PATH) -> Dictionary:
	return _load_from_path(path)


func restore_previous_save() -> Dictionary:
	return _load_from_path(PREVIOUS_AUTOSAVE_PATH)


func _handle_death(reason: String) -> Dictionary:
	state = TravelState.DEAD
	state_changed.emit()
	var restored := restore_previous_save()
	died.emit()
	if restored.ok:
		return _failure("%s Previous save restored." % reason)
	return _failure("%s No previous save is available." % reason)


func _load_from_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("No save file exists.")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("Save file could not be opened.")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return _failure("Save file is invalid.")
	var loaded_planet_id := StringName(parsed.get("current_planet_id", ""))
	var loaded_resources: Variant = parsed.get("resources", {})
	var loaded_hull_hp := float(parsed.get("hull_hp", -1.0))
	var loaded_defense_pool := float(parsed.get("defense_pool", 0.0))
	if loaded_planet_id.is_empty() or typeof(loaded_resources) != TYPE_DICTIONARY or not is_finite(loaded_hull_hp) or loaded_hull_hp <= 0.0 or not is_finite(loaded_defense_pool) or loaded_defense_pool < 0.0:
		return _failure("Saved game state is invalid.")
	var loaded_travel: TravelDefinition
	var loaded_event: EventDefinition
	var loaded_travel_elapsed := 0.0
	var loaded_segment_index := 0
	var travel_id := StringName(parsed.get("travel_id", ""))
	if not travel_id.is_empty():
		if not content_lookup.is_valid():
			return _failure("Travel content resolver is unavailable.")
		loaded_travel = content_lookup.call("travel", travel_id) as TravelDefinition
		if loaded_travel == null or not loaded_travel.is_valid_definition():
			return _failure("Saved travel data is unavailable.")
		if loaded_travel.origin_planet_id != loaded_planet_id:
			return _failure("Saved travel origin does not match the saved planet.")
		loaded_travel_elapsed = float(parsed.get("travel_elapsed", 0.0))
		loaded_segment_index = int(parsed.get("travel_segment_index", 0))
		if loaded_segment_index < 0 or loaded_segment_index >= loaded_travel.segment_durations_seconds.size() or not is_finite(loaded_travel_elapsed) or loaded_travel_elapsed < 0.0 or loaded_travel_elapsed >= loaded_travel.segment_durations_seconds[loaded_segment_index]:
			return _failure("Saved travel progress is invalid.")
		var event_id := StringName(parsed.get("pending_event_id", ""))
		if not event_id.is_empty():
			loaded_event = content_lookup.call("event", event_id) as EventDefinition
			if loaded_event == null or not loaded_event.is_valid_definition():
				return _failure("Saved event data is unavailable.")
		if String(parsed.get("state", "")) == "EVENT_PAUSED" and loaded_event == null:
			return _failure("Saved event state is incomplete.")
	elif not StringName(parsed.get("pending_event_id", "")).is_empty():
		return _failure("Saved event has no active travel route.")
	current_planet_id = loaded_planet_id
	resources = loaded_resources.duplicate(true)
	hull_hp = loaded_hull_hp
	defense_pool = loaded_defense_pool
	travel = loaded_travel
	pending_event = loaded_event
	travel_elapsed = loaded_travel_elapsed
	travel_segment_index = loaded_segment_index
	if travel != null:
		state = TravelState.EVENT_PAUSED if pending_event != null else TravelState.TRAVELLING
	else:
		state = TravelState.DOCKED
	_save_payload = parsed
	state_changed.emit()
	return _success()


func _success() -> Dictionary:
	return {"ok": true, "reason": ""}


func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
