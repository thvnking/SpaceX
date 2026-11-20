extends Control
class_name InventoryGridView

signal placement_failed(reason: String)
signal inventory_changed

const CELL_SIZE := 48.0
const GRID_LINE := Color("34465d")
const EMPTY_CELL := Color("111e2e")
const CORE_CELL := Color("25374a")
const ITEM_CELL := Color("24645f")
const PREVIEW_VALID := Color(0.25, 0.82, 0.69, 0.42)
const PREVIEW_INVALID := Color(0.92, 0.28, 0.31, 0.42)

var model: InventoryModel
var selected_item: ItemInstance
var selected_cell_offset := Vector2i.ZERO
var hovered_cell := Vector2i.ZERO
var has_hover := false
var travelling := false
var last_reason := ""


func bind_model(inventory_model: InventoryModel) -> void:
	model = inventory_model
	queue_redraw()


func set_travelling(value: bool) -> void:
	travelling = value
	queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(220, 220)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	if model == null or model.ship == null or not model.ship.is_valid_definition():
		_draw_message("Ship layout is not configured.")
		return
	var bounds := _grid_bounds()
	if bounds.is_empty():
		_draw_message("Ship has no usable inventory cells.")
		return
	var origin := _grid_origin(bounds)
	for cell in model.ship.valid_grid_cells:
		var rect := _cell_rect(cell, bounds, origin)
		var color := CORE_CELL if model.ship.is_core_cell(cell) else EMPTY_CELL
		draw_rect(rect, color, true)
		draw_rect(rect, GRID_LINE, false, 1.0)
		if model.ship.is_core_cell(cell):
			var component := _core_name(cell)
			if not component.is_empty():
				_draw_centered_text(component, rect, 10, Color("aebdd0"))
	for instance in model.items:
		if instance == null or instance.delivered or instance.definition == null:
			continue
		for cell in instance.occupied_cells():
			var rect := _cell_rect(cell, bounds, origin).grow(-2.0)
			draw_rect(rect, ITEM_CELL, true)
			var border := Color("65d6c4") if instance == selected_item else Color("3b8f88")
			draw_rect(rect, border, false, 2.0 if instance == selected_item else 1.0)
		var label_rect := _cell_rect(instance.grid_position, bounds, origin)
		_draw_centered_text(instance.definition.display_name, label_rect, 10, Color.WHITE)
	if selected_item != null and has_hover:
		var anchor := hovered_cell - selected_cell_offset
		var result := model.validate_placement(selected_item, anchor, selected_item.rotation_quarters, selected_item)
		var preview_color := PREVIEW_VALID if result.valid and not travelling else PREVIEW_INVALID
		for cell in selected_item.occupied_cells(anchor, selected_item.rotation_quarters):
			draw_rect(_cell_rect(cell, bounds, origin).grow(-2.0), preview_color, true)
	if travelling:
		_draw_message("Inventory locked during travel.")
	elif not last_reason.is_empty():
		draw_string(get_theme_default_font(), Vector2(8, size.y - 10), last_reason, HORIZONTAL_ALIGNMENT_LEFT, size.x - 16, 11, Color("ff9e9e"))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell := _cell_at(event.position)
		has_hover = cell.x != -2147483648
		if has_hover:
			hovered_cell = cell
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if travelling or model == null:
			return
		var cell := _cell_at(event.position)
		if cell.x == -2147483648:
			return
		var clicked_item := _item_at(cell)
		if clicked_item != null:
			selected_item = clicked_item
			selected_cell_offset = cell - clicked_item.grid_position
			last_reason = ""
			accept_event()
			queue_redraw()
			return
		if selected_item != null:
			var result := model.try_place(selected_item, cell - selected_cell_offset, selected_item.rotation_quarters)
			last_reason = result.reason
			if not result.valid:
				placement_failed.emit(result.reason)
			else:
				inventory_changed.emit()
			accept_event()
			queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		if selected_item == null or travelling or model == null:
			return
		selected_item.rotation_quarters = posmod(selected_item.rotation_quarters + 1, 4)
		selected_cell_offset = Vector2i.ZERO
		last_reason = ""
		accept_event()
		queue_redraw()


func _item_at(cell: Vector2i) -> ItemInstance:
	for instance in model.items:
		if instance != null and not instance.delivered and instance.occupied_cells().has(cell):
			return instance
	return null


func _grid_bounds() -> Dictionary:
	if model == null or model.ship == null or model.ship.valid_grid_cells.is_empty():
		return {}
	var min_x := model.ship.valid_grid_cells[0].x
	var max_x := min_x
	var min_y := model.ship.valid_grid_cells[0].y
	var max_y := min_y
	for cell in model.ship.valid_grid_cells:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)
	return {"min_x": min_x, "max_x": max_x, "min_y": min_y, "max_y": max_y}


func _grid_origin(bounds: Dictionary) -> Vector2:
	var columns := int(bounds.max_x) - int(bounds.min_x) + 1
	var rows := int(bounds.max_y) - int(bounds.min_y) + 1
	var grid_size := Vector2(columns * CELL_SIZE, rows * CELL_SIZE)
	return (size - grid_size) * 0.5 - Vector2(float(bounds.min_x), float(bounds.min_y)) * CELL_SIZE


func _cell_rect(cell: Vector2i, bounds: Dictionary, origin: Vector2) -> Rect2:
	return Rect2(origin + Vector2(cell.x, cell.y) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))


func _cell_at(point: Vector2) -> Vector2i:
	var bounds := _grid_bounds()
	if bounds.is_empty():
		return Vector2i(-2147483648, -2147483648)
	var local_grid := point - _grid_origin(bounds)
	var cell := Vector2i(floori(local_grid.x / CELL_SIZE), floori(local_grid.y / CELL_SIZE))
	if not model.ship.valid_grid_cells.has(cell):
		return Vector2i(-2147483648, -2147483648)
	return cell


func _core_name(cell: Vector2i) -> String:
	for component in model.ship.core_component_cells:
		if model.ship.core_component_cells[component] == cell:
			return String(component).replace("_", " ").to_upper()
	return ""


func _draw_centered_text(value: String, rect: Rect2, font_size: int, color: Color) -> void:
	var font := get_theme_default_font()
	var text_size := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var position := rect.position + (rect.size - text_size) * 0.5 + Vector2(0, font.get_ascent(font_size) * 0.35)
	draw_string(font, position, value, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x, font_size, color)


func _draw_message(value: String) -> void:
	_draw_centered_text(value, Rect2(Vector2.ZERO, size), 12, Color("91a2b8"))
