extends Resource
class_name PlanetDefinition

@export var id: StringName
@export var display_name: String
@export var civilization_present: bool = false
@export_enum("Civilization", "Colony", "Extraction") var world_type: String = "Colony"
@export var system_id: StringName
@export var owner_name: String = "Mars"
@export var resource_notes: PackedStringArray = []
@export var connected_planet_ids: Array[StringName] = []
@export var resource_refill: Dictionary = {}
@export var market_item_ids: Array[StringName] = []


func is_valid_definition() -> bool:
	if id.is_empty() or display_name.strip_edges().is_empty():
		return false
	for refill_amount in resource_refill.values():
		if typeof(refill_amount) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(refill_amount)) or float(refill_amount) < 0.0:
			return false
	return true
