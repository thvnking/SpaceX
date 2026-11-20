extends RefCounted
class_name DemoContent

## Small replaceable scenario for testing the documented MVP loop.
static func install(catalog: ContentCatalog) -> GameSetupDefinition:
	var ship := ShipDefinition.new()
	ship.id = &"demo_courier"
	ship.display_name = "Demo Courier"
	for y in 4:
		for x in 5:
			ship.valid_grid_cells.append(Vector2i(x, y))
	ship.core_component_cells = {
		"cockpit": Vector2i(0, 1),
		"engine": Vector2i(4, 1),
		"energy_room": Vector2i(3, 1),
	}
	ship.cell_tags = {"3,3": PackedStringArray(["high_heat"])}
	catalog.register_definition("ship", ship)

	var parcel := ItemDefinition.new()
	parcel.id = &"demo_parcel"
	parcel.display_name = "Survey Parcel"
	parcel.item_type = ItemDefinition.ItemType.CARGO
	parcel.shape_cells = [Vector2i.ZERO]
	parcel.tags = PackedStringArray(["Cargo", "Demo"])
	parcel.rarity_level = 0
	parcel.origin_culture = "Demo"
	parcel.cargo_value = 20
	parcel.buy_price = 18
	parcel.sell_price = 15
	parcel.sell_reputation_delta = -1
	catalog.register_definition("item", parcel)

	var recycler := ItemDefinition.new()
	recycler.id = &"demo_recycler"
	recycler.display_name = "Recycling Unit"
	recycler.item_type = ItemDefinition.ItemType.EQUIPMENT
	recycler.shape_cells = [Vector2i.ZERO, Vector2i.RIGHT]
	recycler.tags = PackedStringArray(["Equipment", "Demo"])
	recycler.rarity_level = 1
	recycler.origin_culture = "Demo"
	recycler.buy_price = 24
	recycler.sell_price = 12
	var avoid_heat := PlacementRule.new()
	avoid_heat.rule_type = &"avoid_cell_tag"
	avoid_heat.parameters = {"tag": "high_heat"}
	recycler.placement_rules = [avoid_heat]
	catalog.register_definition("item", recycler)

	var starting_parcel := _make_instance("demo_parcel_start", parcel, Vector2i(1, 0))
	var starting_recycler := _make_instance("demo_recycler_start", recycler, Vector2i(1, 2))

	var event := EventDefinition.new()
	event.id = &"demo_supply_question"
	event.prompt_source = "assistant"
	event.question = "A drifting supply pod crosses the route. What should the ship prioritize?"
	event.choice_labels = PackedStringArray(["Hold course", "Recover the pod"])
	event.choice_effects = [
		{"resource_delta": {"food": -1, "fuel": -1}},
		{"resource_delta": {"food": -2, "fuel": 3}},
	]
	catalog.register_definition("event", event)

	var combat := CombatDefinition.new()
	combat.id = &"demo_patrol"
	combat.attack_duration_seconds = 4.0
	combat.starting_enemy_count = 1
	combat.special_equipment_can_resolve = true
	catalog.register_definition("combat", combat)

	var origin := _make_planet("demo_origin", "Launch Port", true, {"food": 10.0, "fuel": 10.0})
	origin.system_id = &"system_01"
	origin.world_type = "Civilization"
	origin.connected_planet_ids = [&"demo_relay"]
	origin.market_item_ids = [&"demo_parcel", &"demo_recycler"]
	catalog.register_definition("planet", origin)
	var relay := _make_planet("demo_relay", "Waystation", false, {"food": 8.0, "fuel": 8.0})
	relay.system_id = &"system_02"
	relay.world_type = "Colony"
	relay.connected_planet_ids = [&"demo_origin", &"demo_destination"]
	catalog.register_definition("planet", relay)
	var destination := _make_planet("demo_destination", "Harbor Station", true, {"food": 10.0, "fuel": 10.0})
	destination.system_id = &"system_04"
	destination.world_type = "Civilization"
	destination.connected_planet_ids = [&"demo_relay"]
	destination.market_item_ids = [&"demo_parcel", &"demo_recycler"]
	catalog.register_definition("planet", destination)
	var map_worlds := [
		["orison_outer", "Pallas Reach", "Colony", 1, {"food": 4.0, "fuel": 3.0}, []],
		["veyra_mine", "Cobalt Shelf", "Extraction", 2, {"food": 1.0, "fuel": 7.0}, ["Cobalt", "Nickel"]],
		["serein_colony", "Lumen", "Colony", 3, {"food": 4.0, "fuel": 3.0}, []],
		["serein_mine", "Orrery-3", "Extraction", 3, {"food": 1.0, "fuel": 6.0}, ["Silicates"]],
		["caldera_outer", "Redoubt", "Colony", 4, {"food": 4.0, "fuel": 3.0}, []],
		["morrow_colony", "Morrow Haven", "Colony", 5, {"food": 4.0, "fuel": 3.0}, []],
		["morrow_mine", "The Shards", "Extraction", 5, {"food": 1.0, "fuel": 7.0}, ["Iron", "Rare earths"]],
		["ilyon_colony", "Sable", "Colony", 6, {"food": 4.0, "fuel": 3.0}, []],
		["ilyon_mine", "Vesper Quarry", "Extraction", 6, {"food": 1.0, "fuel": 6.0}, ["Titanium"]],
		["aster_civ", "Aster Commons", "Civilization", 7, {"food": 10.0, "fuel": 10.0}, []],
		["aster_mine", "Verdant Moon", "Extraction", 7, {"food": 1.0, "fuel": 6.0}, ["Bio-gel"]],
		["nacre_colony", "Nacre One", "Colony", 8, {"food": 4.0, "fuel": 3.0}, []],
		["nacre_mine", "Deepwell", "Extraction", 8, {"food": 1.0, "fuel": 7.0}, ["Helium-3"]],
		["cinder_civ", "Cinderfall", "Civilization", 9, {"food": 10.0, "fuel": 10.0}, []],
		["cinder_outer", "Ashline", "Colony", 9, {"food": 4.0, "fuel": 3.0}, []],
		["pelagos_colony", "Pelagos Station", "Colony", 10, {"food": 4.0, "fuel": 3.0}, []],
		["pelagos_mine", "Blue Vault", "Extraction", 10, {"food": 1.0, "fuel": 7.0}, ["Water ice"]],
	]
	var all_map_planets: Array[StringName] = [&"demo_origin", &"demo_relay", &"demo_destination"]
	for world in map_worlds:
		var planet := _make_planet(String(world[0]), String(world[1]), String(world[2]) == "Civilization", world[4])
		planet.world_type = String(world[2])
		planet.system_id = StringName("system_%02d" % int(world[3]))
		planet.resource_notes = PackedStringArray(world[5])
		catalog.register_definition("planet", planet)
		all_map_planets.append(planet.id)

	var outbound := _make_travel("demo_origin_to_relay", "demo_origin", "demo_relay", [6.0, 6.0])
	outbound.segment_events = {0: event}
	outbound.segment_combats = {1: combat.id}
	catalog.register_definition("travel", outbound)
	catalog.register_definition("travel", _make_travel("demo_relay_to_origin", "demo_relay", "demo_origin", [6.0, 6.0]))
	catalog.register_definition("travel", _make_travel("demo_relay_to_destination", "demo_relay", "demo_destination", [6.0, 6.0]))
	catalog.register_definition("travel", _make_travel("demo_destination_to_relay", "demo_destination", "demo_relay", [6.0, 6.0]))
	var system_positions := [Vector2(0.48, 0.51), Vector2(0.59, 0.42), Vector2(0.68, 0.32), Vector2(0.38, 0.39), Vector2(0.30, 0.57), Vector2(0.42, 0.70), Vector2(0.61, 0.64), Vector2(0.76, 0.50), Vector2(0.79, 0.72), Vector2(0.22, 0.35)]
	var known_routes := {"demo_origin|demo_relay": true, "demo_relay|demo_origin": true, "demo_relay|demo_destination": true, "demo_destination|demo_relay": true}
	for origin_id in all_map_planets:
		var origin_planet := catalog.get_definition("planet", origin_id) as PlanetDefinition
		var origin_index := _system_index(origin_planet.system_id)
		for destination_id in all_map_planets:
			if origin_id == destination_id:
				continue
			var route_pair := "%s|%s" % [origin_id, destination_id]
			if known_routes.has(route_pair):
				continue
			var route_id := StringName("map_%s_to_%s" % [origin_id, destination_id])
			var destination_planet := catalog.get_definition("planet", destination_id) as PlanetDefinition
			var destination_index := _system_index(destination_planet.system_id)
			var distance: float = system_positions[origin_index].distance_to(system_positions[destination_index])
			var travel_seconds := maxf(8.0, distance * 70.0)
			if origin_index == destination_index:
				travel_seconds = 8.0
			catalog.register_definition("travel", _make_travel(String(route_id), String(origin_id), String(destination_id), [travel_seconds]))

	var mission := MissionDefinition.new()
	mission.id = &"demo_delivery"
	mission.display_name = "Deliver the Survey Parcel"
	mission.delivery_target_planet_id = &"demo_destination"
	mission.required_cargo = [{"definition_id": "demo_parcel", "quantity": 1}]
	mission.reward_data = {"credits": 12, "reputation_xp": 1}
	catalog.register_definition("mission", mission)

	var setup := GameSetupDefinition.new()
	setup.starting_planet_id = &"demo_origin"
	setup.starting_ship_id = ship.id
	setup.starting_items = [starting_parcel, starting_recycler]
	setup.starting_resource_values = {"food": 40.0, "fuel": 40.0}
	setup.starting_hull_hp = 20.0
	setup.starting_credits = 30
	setup.starting_mission_id = mission.id
	return setup


static func _make_instance(instance_id: String, definition: ItemDefinition, position: Vector2i) -> ItemInstance:
	var instance := ItemInstance.new()
	instance.instance_id = StringName(instance_id)
	instance.definition = definition
	instance.grid_position = position
	return instance


static func _make_planet(id: String, title: String, has_civilization: bool, refill: Dictionary) -> PlanetDefinition:
	var planet := PlanetDefinition.new()
	planet.id = StringName(id)
	planet.display_name = title
	planet.civilization_present = has_civilization
	planet.world_type = "Civilization" if has_civilization else "Colony"
	planet.resource_refill = refill
	return planet


static func _system_index(system_id: StringName) -> int:
	var value := String(system_id).trim_prefix("system_")
	return clampi(value.to_int() - 1, 0, 9)


static func _make_travel(id: String, origin_id: String, destination_id: String, segment_durations: Array[float]) -> TravelDefinition:
	var travel := TravelDefinition.new()
	travel.id = StringName(id)
	travel.origin_planet_id = StringName(origin_id)
	travel.destination_planet_id = StringName(destination_id)
	travel.segment_durations_seconds = segment_durations
	travel.resource_drain_per_second = {"food": 0.1, "fuel": 0.2}
	return travel
