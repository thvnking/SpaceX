extends Resource
class_name GameSetupDefinition

@export var starting_planet_id: StringName
@export var starting_ship_id: StringName
@export var starting_items: Array[ItemInstance] = []
@export var starting_resource_values: Dictionary = {}
@export var starting_hull_hp: float = -1.0
@export var starting_credits: int = 0
@export var starting_mission_id: StringName


func is_valid_definition(catalog: ContentCatalog) -> bool:
	if catalog == null or starting_planet_id.is_empty() or starting_ship_id.is_empty() or not is_finite(starting_hull_hp) or starting_hull_hp <= 0.0:
		return false
	if not starting_resource_values.has("food") or typeof(starting_resource_values.food) not in [TYPE_INT, TYPE_FLOAT] or float(starting_resource_values.food) <= 0.0:
		return false
	for resource_id in starting_resource_values:
		var resource_value: Variant = starting_resource_values[resource_id]
		if typeof(resource_value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(resource_value)) or float(resource_value) < 0.0:
			return false
	var planet := catalog.get_definition("planet", starting_planet_id) as PlanetDefinition
	var ship := catalog.get_definition("ship", starting_ship_id) as ShipDefinition
	if planet == null or not planet.is_valid_definition() or ship == null or not ship.is_valid_definition():
		return false
	if starting_credits < 0:
		return false
	if not starting_mission_id.is_empty():
		var mission := catalog.get_definition("mission", starting_mission_id) as MissionDefinition
		if mission == null or not mission.is_valid_definition():
			return false
		var target := catalog.get_definition("planet", mission.delivery_target_planet_id) as PlanetDefinition
		if target == null or not target.is_valid_definition():
			return false
	for instance in starting_items:
		if instance == null or instance.definition == null or not instance.definition.is_valid_definition():
			return false
		var registered_item := catalog.get_definition("item", instance.definition.id) as ItemDefinition
		if registered_item == null:
			return false
	return true
