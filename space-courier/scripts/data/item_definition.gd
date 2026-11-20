extends Resource
class_name ItemDefinition

enum ItemType { CARGO, EQUIPMENT }

@export var id: StringName
@export var display_name: String
@export var item_type: ItemType = ItemType.CARGO
@export var shape_cells: Array[Vector2i] = []
@export var tags: PackedStringArray = []
@export var rarity_level: int = -1
@export var origin_culture: String
@export var effects: Array[Dictionary] = []
@export var placement_rules: Array[PlacementRule] = []
@export var cargo_value: int = -1
@export var buy_price: int = -1
@export var sell_price: int = -1
@export var sell_reputation_delta: int = 0
@export var delivery_planet_id: StringName
@export var special_cargo: bool = false
@export var has_durability: bool = false
@export var maximum_durability: int = -1
@export var maximum_ammo: int = -1


func get_rotated_shape(rotation_quarters: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var turns := posmod(rotation_quarters, 4)
	for cell in shape_cells:
		var rotated := cell
		for _turn in turns:
			rotated = Vector2i(-rotated.y, rotated.x)
		result.append(rotated)
	return _normalize_shape(result)


func is_valid_definition() -> bool:
	if id.is_empty() or display_name.strip_edges().is_empty() or shape_cells.is_empty() or tags.is_empty() or rarity_level < 0 or rarity_level > 3:
		return false
	if has_durability and maximum_durability <= 0:
		return false
	var unique := {}
	for cell in shape_cells:
		unique[cell] = true
	return unique.size() == shape_cells.size()


func _normalize_shape(shape: Array[Vector2i]) -> Array[Vector2i]:
	if shape.is_empty():
		return shape
	var min_x := shape[0].x
	var min_y := shape[0].y
	for cell in shape:
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)
	var normalized: Array[Vector2i] = []
	for cell in shape:
		normalized.append(cell - Vector2i(min_x, min_y))
	return normalized
