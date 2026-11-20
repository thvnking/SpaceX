extends Resource
class_name ItemInstance

@export var instance_id: StringName
@export var definition: ItemDefinition
@export var grid_position: Vector2i = Vector2i.ZERO
@export_range(0, 3) var rotation_quarters: int = 0
@export var current_state: Dictionary = {}
@export var durability_current: int = -1
@export var delivered: bool = false


func occupied_cells(position_override := Vector2i(-2147483648, -2147483648), rotation_override := -1) -> Array[Vector2i]:
	var anchor := grid_position if position_override.x == -2147483648 else position_override
	var turns := rotation_quarters if rotation_override < 0 else rotation_override
	var result: Array[Vector2i] = []
	if definition == null:
		return result
	for cell in definition.get_rotated_shape(turns):
		result.append(anchor + cell)
	return result
