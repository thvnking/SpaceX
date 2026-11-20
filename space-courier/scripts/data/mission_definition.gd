extends Resource
class_name MissionDefinition

@export var id: StringName
@export var display_name: String
@export var delivery_target_planet_id: StringName
## Each entry references an item definition and an author supplied quantity.
@export var required_cargo: Array[Dictionary] = []
@export var trip_count_or_completion_conditions: Dictionary = {}
@export var reward_data: Dictionary = {}


func is_valid_definition() -> bool:
	return not id.is_empty() and not display_name.strip_edges().is_empty() and not delivery_target_planet_id.is_empty()
