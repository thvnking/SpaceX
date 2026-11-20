extends RefCounted
class_name InventoryModel

## Shared cargo and equipment grid model. This class does not depend on UI.

var ship: ShipDefinition
var items: Array[ItemInstance] = []


func configure(ship_definition: ShipDefinition, starting_items: Array[ItemInstance] = []) -> void:
	ship = ship_definition
	items = starting_items.duplicate()


func validate_placement(instance: ItemInstance, anchor: Vector2i, rotation_quarters: int, ignore_instance: ItemInstance = null) -> Dictionary:
	if ship == null or not ship.is_valid_definition():
		return _invalid("Ship layout is not configured.")
	if instance == null or instance.definition == null or not instance.definition.is_valid_definition():
		return _invalid("Item definition is incomplete.")
	var candidate := instance.occupied_cells(anchor, rotation_quarters)
	if candidate.is_empty():
		return _invalid("Item shape is empty.")
	var valid_cells := {}
	for cell in ship.valid_grid_cells:
		valid_cells[cell] = true
	for cell in candidate:
		if not valid_cells.has(cell):
			return _invalid("Item extends outside the ship layout.")
		if ship.is_core_cell(cell):
			return _invalid("Item cannot cover a ship core component.")
	for other in items:
		if other == ignore_instance or other == instance or other.delivered or other.definition == null:
			continue
		for occupied in other.occupied_cells():
			if candidate.has(occupied):
				return _invalid("Items cannot overlap.")
	return _validate_rules(instance.definition, candidate, ignore_instance)


func try_place(instance: ItemInstance, anchor: Vector2i, rotation_quarters: int) -> Dictionary:
	var result := validate_placement(instance, anchor, rotation_quarters, instance)
	if not result.valid:
		return result
	instance.grid_position = anchor
	instance.rotation_quarters = posmod(rotation_quarters, 4)
	if not items.has(instance):
		items.append(instance)
	return result


func remove_item(instance: ItemInstance) -> bool:
	if not items.has(instance):
		return false
	items.erase(instance)
	return true


func can_rearrange(is_travelling: bool) -> bool:
	return not is_travelling


func _validate_rules(definition: ItemDefinition, cells: Array[Vector2i], ignore_instance: ItemInstance) -> Dictionary:
	var occupied_cell_tags := PackedStringArray()
	var adjacent_tags := PackedStringArray()
	var forbidden_cell_tags := PackedStringArray()
	for cell in cells:
		for tag in ship.tags_for_cell(cell):
			_append_unique(occupied_cell_tags, tag)
			_append_unique(forbidden_cell_tags, tag)
		for neighbor in _neighbors(cell):
			for tag in ship.tags_for_cell(neighbor):
				_append_unique(adjacent_tags, tag)
			for other in items:
				if other == ignore_instance or other.delivered or other.definition == null:
					continue
				if other.occupied_cells().has(neighbor):
					for tag in other.definition.tags:
						_append_unique(adjacent_tags, tag)
	for rule in definition.placement_rules:
		if rule == null:
			return _invalid("Placement rule data is incomplete.")
		var tag := String(rule.parameters.get("tag", ""))
		if tag.is_empty():
			return _invalid("Placement rule '%s' has no tag." % rule.rule_type)
		match rule.rule_type:
			&"require_cell_tag":
				if not occupied_cell_tags.has(tag):
					return _invalid("Placement requires a cell tagged '%s'." % tag)
			&"avoid_cell_tag":
				if forbidden_cell_tags.has(tag):
					return _invalid("Placement must avoid cells tagged '%s'." % tag)
			&"require_adjacent_tag":
				if not adjacent_tags.has(tag):
					return _invalid("Placement requires an adjacent '%s' tag." % tag)
			&"avoid_adjacent_tag":
				if adjacent_tags.has(tag):
					return _invalid("Placement must avoid adjacent '%s' tags." % tag)
			_:
				return _invalid("Placement rule '%s' is not supported yet." % rule.rule_type)
	return {"valid": true, "reason": ""}


func _append_unique(values: PackedStringArray, value: String) -> void:
	if not values.has(value):
		values.append(value)


func _neighbors(cell: Vector2i) -> Array[Vector2i]:
	return [cell + Vector2i.UP, cell + Vector2i.RIGHT, cell + Vector2i.DOWN, cell + Vector2i.LEFT]


func _invalid(reason: String) -> Dictionary:
	return {"valid": false, "reason": reason}
