extends Resource
class_name ShipDefinition

@export var id: StringName
@export var display_name: String
@export var valid_grid_cells: Array[Vector2i] = []
@export var cell_tags: Dictionary = {}
@export var core_component_cells: Dictionary = {}
@export var visual_reference: String


func is_valid_definition() -> bool:
	if id.is_empty() or display_name.strip_edges().is_empty() or valid_grid_cells.is_empty():
		return false
	var cells := {}
	for cell in valid_grid_cells:
		cells[cell] = true
	if cells.size() != valid_grid_cells.size():
		return false
	for required_component in ["cockpit", "engine", "energy_room"]:
		if not core_component_cells.has(required_component):
			return false
		if not cells.has(core_component_cells[required_component]):
			return false
	var distinct_core_cells := {}
	for core_cell in core_component_cells.values():
		distinct_core_cells[core_cell] = true
	if distinct_core_cells.size() != core_component_cells.size():
		return false
	return true


func is_core_cell(cell: Vector2i) -> bool:
	return core_component_cells.values().has(cell)


func tags_for_cell(cell: Vector2i) -> PackedStringArray:
	var key := "%d,%d" % [cell.x, cell.y]
	var value: Variant = cell_tags.get(key, PackedStringArray())
	if value is PackedStringArray:
		return value
	if value is Array:
		return PackedStringArray(value)
	return PackedStringArray()
