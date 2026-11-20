extends Control

const PANEL := Color("101a29")
const PANEL_LIGHT := Color("162337")
const LINE := Color("27364b")
const TEXT := Color("e7edf5")
const MUTED := Color("91a2b8")
const ACCENT := Color("65d6c4")

var page_stack: Control
var header_bar: Control
var navigation_bar: Control
var nav_buttons: Dictionary = {}
var current_page := "ship"
var save_page_mode := "load"
var return_page := "menu"
var settings_return_page := "menu"
var gameplay_return_page := "ship"
var runtime: GameRuntime
var travel_status_value: Label
var destination_status_value: Label
var ship_status_value: Label
var food_status_value: Label
var fuel_status_value: Label
var save_button: Button
var load_button: Button
var event_overlay: PanelContainer
var event_question_label: Label
var event_choice_buttons: Array[Button] = []
var route_list: VBoxContainer
var galaxy_map: GalaxyMapView
var selected_system_label: Label
var selected_system_detail: Label
var inventory_grid: InventoryGridView
var inventory_count_label: Label
var message_banner: PanelContainer
var message_label: Label
var message_timer: Timer
var combat_overlay: PanelContainer
var combat_status_label: Label
var combat_special_button: Button
var save_slots_list: VBoxContainer
var save_page_title: Label
var settings_master_slider: HSlider
var settings_music_slider: HSlider
var settings_sfx_slider: HSlider
var settings_resolution: OptionButton
var settings_window_mode: OptionButton
var delete_dialog: ConfirmationDialog
var pending_delete_slot := -1
var overwrite_dialog: ConfirmationDialog
var pending_save_slot := -1
var new_game_dialog: ConfirmationDialog
var pause_overlay: PanelContainer
var mission_title_label: Label
var mission_detail_label: Label
var delivery_button: Button
var hub_location_label: Label
var hub_credits_label: Label
var hub_market_list: VBoxContainer


func _ready() -> void:
	runtime = GameRuntime.new()
	add_child(runtime)
	runtime.status_updated.connect(_refresh_status)
	runtime.event_opened.connect(_show_event)
	runtime.combat_opened.connect(_show_combat)
	runtime.arrival_completed.connect(_on_arrival)
	runtime.game_over.connect(_show_message)
	_build_interface()
	_set_game_chrome(false)
	_show_page("menu")
	_refresh_status()
	if runtime.session.pending_event != null:
		_show_event(runtime.session.pending_event)


func _process(_delta: float) -> void:
	_refresh_combat()


func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 0)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	header_bar = _build_top_bar()
	root.add_child(header_bar)
	navigation_bar = _build_navigation()
	root.add_child(navigation_bar)
	page_stack = Control.new()
	page_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(page_stack)
	_build_ship_page()
	_build_shipyard_page()
	_build_map_page()
	_build_orders_page()
	_build_hub_page()
	_build_menu_page()
	_build_settings_page()
	_build_saves_page()
	_build_credits_page()
	_build_event_overlay()
	_build_combat_overlay()
	_build_message_banner()
	_build_pause_overlay()
	_build_dialogs()


func _build_top_bar() -> Control:
	var bar := PanelContainer.new()
	bar.custom_minimum_size.y = 76
	var bar_style := _style(PANEL, LINE, 0, 0)
	bar_style.content_margin_left = 28
	bar_style.content_margin_right = 28
	bar_style.content_margin_top = 8
	bar_style.content_margin_bottom = 8
	bar.add_theme_stylebox_override("panel", bar_style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.add_theme_stylebox_override("panel", _style(PANEL, LINE, 0, 0))
	bar.add_child(row)

	var brand := VBoxContainer.new()
	brand.add_theme_constant_override("separation", 2)
	var title := _label("SPACE COURIER", 18, TEXT, true)
	var subtitle := _label("SHIP MANAGEMENT", 10, MUTED, true)
	brand.add_child(title)
	brand.add_child(subtitle)
	row.add_child(brand)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	row.add_child(_status_chip("TRAVEL", "—"))
	row.add_child(_status_chip("DESTINATION", "Not set"))
	row.add_child(_status_chip("SHIP", "—"))
	row.add_child(_status_chip("FOOD", "—"))
	row.add_child(_status_chip("FUEL", "—"))
	save_button = _header_button("SAVE")
	save_button.pressed.connect(_save_game)
	row.add_child(save_button)
	load_button = _header_button("LOAD")
	load_button.pressed.connect(_load_game)
	row.add_child(load_button)
	return bar


func _build_navigation() -> Control:
	var bar := PanelContainer.new()
	bar.custom_minimum_size.y = 58
	var bar_style := _style(Color("0c1420"), LINE, 0, 0)
	bar_style.content_margin_left = 28
	bar_style.content_margin_right = 28
	bar_style.content_margin_top = 5
	bar_style.content_margin_bottom = 5
	bar.add_theme_stylebox_override("panel", bar_style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	bar.add_child(row)
	for item in [["ship", "SHIP"], ["shipyard", "SHIPYARD"], ["map", "MAP"], ["orders", "ORDERS"], ["hub", "HUB"]]:
		var button := Button.new()
		button.text = item[1]
		button.custom_minimum_size = Vector2(112, 38)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 12)
		button.add_theme_color_override("font_color", MUTED)
		button.add_theme_color_override("font_hover_color", TEXT)
		button.add_theme_stylebox_override("normal", _style(Color("0c1420"), Color("0c1420"), 0, 0))
		button.add_theme_stylebox_override("hover", _style(PANEL_LIGHT, LINE, 5, 1))
		button.pressed.connect(_show_page.bind(item[0]))
		nav_buttons[item[0]] = button
		row.add_child(button)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var note := _label("LAYOUT PREVIEW  ·  ARTWORK TO COME", 10, MUTED, true)
	row.add_child(note)
	return bar


func _build_shipyard_page() -> void:
	var page := _new_page("shipyard")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	page.add_child(column)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 18)
	column.add_child(heading)
	var title_block := VBoxContainer.new()
	title_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_block.add_child(_label("MARS UNION SHIPYARDS", 20, TEXT, true))
	title_block.add_child(_label("CÔNG TY LIÊN HIỆP SAO HỎA  /  A CHARTERED MERCANTILE FLEET", 10, MUTED, true))
	heading.add_child(title_block)
	var seal := _header_button("MARS FEDERATION  ·  CHARTERED")
	seal.custom_minimum_size.x = 250
	heading.add_child(seal)
	var intro := _panel()
	intro.add_child(_padded_label("Đội tàu thương mại của Liên Ban Sao Hỏa — kết cấu công nghiệp vuông vức, góc bo chịu lực, vỏ gốm trắng và các mảng cam nhận diện. Ba cấu hình dưới đây tăng dần về kích thước, độ hiếm và giá niêm yết.", 12, TEXT))
	column.add_child(intro)
	var fleet := HBoxContainer.new()
	fleet.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fleet.add_theme_constant_override("separation", 12)
	column.add_child(fleet)
	var ships := [
		{"code":"MU-01", "name":"PIONEER", "role":"COURIER / SHORT HAUL", "rarity":"COMMON", "size":"SMALL · 4 × 3 CELLS", "price":"120 CR", "color":Color("9caebd"), "variant":0, "stats":"CREW  02     CARGO  06     RANGE  02"},
		{"code":"MU-04", "name":"FACTOR", "role":"TRADE CARRIER / GENERAL", "rarity":"UNCOMMON", "size":"MEDIUM · 6 × 4 CELLS", "price":"380 CR", "color":Color("ff9c55"), "variant":1, "stats":"CREW  04     CARGO  14     RANGE  04"},
		{"code":"MU-09", "name":"GALLEON", "role":"DEEP ROUTE / HEAVY HAUL", "rarity":"RARE", "size":"LARGE · 8 × 5 CELLS", "price":"960 CR", "color":Color("e5b86d"), "variant":2, "stats":"CREW  08     CARGO  28     RANGE  07"},
	]
	for data in ships:
		fleet.add_child(_shipyard_card(data))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 8)
	foot.add_child(_label("M.U.C.  ·  MARS FEDERATION", 10, Color("ff8a4c"), true))
	foot.add_child(_label("/", 10, MUTED))
	foot.add_child(_label("DESIGN STUDY 01     •     VALUES ARE PROVISIONAL", 10, MUTED, true))
	column.add_child(foot)


func _shipyard_card(data: Dictionary) -> Control:
	var card := _panel()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.add_theme_constant_override("margin_left", 14)
	body.add_theme_constant_override("margin_right", 14)
	body.add_theme_constant_override("margin_top", 12)
	body.add_theme_constant_override("margin_bottom", 12)
	card.add_child(body)
	var meta := HBoxContainer.new()
	meta.add_child(_label(data.code, 10, Color("ff8a4c"), true))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.add_child(spacer)
	meta.add_child(_label(data.rarity, 10, data.color, true))
	body.add_child(meta)
	body.add_child(_label(data.name, 22, TEXT, true))
	body.add_child(_label(data.role, 9, MUTED, true))
	var art := ShipyardSilhouette.new()
	art.variant = data.variant
	art.accent = data.color
	art.custom_minimum_size.y = 150
	body.add_child(art)
	body.add_child(_label(data.size, 10, TEXT, true))
	body.add_child(_label(data.stats, 9, MUTED, true))
	var divider := ColorRect.new()
	divider.color = LINE
	divider.custom_minimum_size.y = 1
	body.add_child(divider)
	var buyrow := HBoxContainer.new()
	var price := _label(data.price, 17, TEXT, true)
	price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buyrow.add_child(price)
	var quote := _header_button("REQUEST QUOTE")
	quote.custom_minimum_size = Vector2(126, 34)
	quote.disabled = true
	buyrow.add_child(quote)
	body.add_child(buyrow)
	return card


func _build_ship_page() -> void:
	var page := _new_page("ship")
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	page.add_child(content)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.3
	left.add_theme_constant_override("separation", 16)
	content.add_child(left)
	left.add_child(_section_header("SHIP LAYOUT", runtime.setup_status))
	var ship_panel := _panel()
	ship_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(ship_panel)
	var ship_body := VBoxContainer.new()
	ship_body.add_theme_constant_override("separation", 16)
	ship_body.add_theme_constant_override("margin_left", 24)
	ship_body.add_theme_constant_override("margin_right", 24)
	ship_body.add_theme_constant_override("margin_top", 24)
	ship_body.add_theme_constant_override("margin_bottom", 24)
	ship_panel.add_child(ship_body)
	var art_placeholder := _placeholder("SHIP VIEW", "Ship artwork will be added later. Configure an approved ship layout to preview its cells.")
	art_placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ship_body.add_child(art_placeholder)
	var core_row := HBoxContainer.new()
	core_row.add_theme_constant_override("separation", 12)
	ship_body.add_child(core_row)
	core_row.add_child(_small_slot("COCKPIT", "Position TBD"))
	core_row.add_child(_small_slot("ENGINE", "Position TBD"))
	core_row.add_child(_small_slot("ENERGY ROOM", "Position TBD"))

	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 330
	right.size_flags_horizontal = Control.SIZE_FILL
	right.add_theme_constant_override("separation", 16)
	content.add_child(right)
	right.add_child(_section_header("SHIP HOLD", "Cargo and equipment share one layout"))
	var hold := _panel()
	hold.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(hold)
	var hold_body := VBoxContainer.new()
	hold_body.add_theme_constant_override("separation", 14)
	hold_body.add_theme_constant_override("margin_left", 20)
	hold_body.add_theme_constant_override("margin_right", 20)
	hold_body.add_theme_constant_override("margin_top", 20)
	hold_body.add_theme_constant_override("margin_bottom", 20)
	hold.add_child(hold_body)
	hold_body.add_child(_label("INVENTORY GRID", 12, TEXT, true))
	inventory_grid = InventoryGridView.new()
	inventory_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_grid.bind_model(runtime.inventory)
	inventory_grid.inventory_changed.connect(_refresh_inventory_count)
	hold_body.add_child(inventory_grid)
	inventory_count_label = _label("0 items", 11, MUTED)
	hold_body.add_child(inventory_count_label)
	var hint := _panel()
	hint.add_child(_padded_label("Cargo and equipment share one grid. Placement checks ship cells, core rooms, overlap and configured rules. Rearrangement is locked during travel.", 12, MUTED))
	right.add_child(hint)


func _build_map_page() -> void:
	var page := _new_page("map")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	page.add_child(column)
	column.add_child(_section_header("GALACTIC SECTOR 07", "Explore the chart · scroll to zoom · drag to pan · select a system"))
	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	column.add_child(content)
	var map_panel := _panel()
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(map_panel)
	galaxy_map = GalaxyMapView.new()
	galaxy_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	galaxy_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	galaxy_map.system_selected.connect(_on_map_system_selected)
	map_panel.add_child(galaxy_map)
	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 300
	side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 10)
	content.add_child(side)
	var detail_panel := _panel()
	side.add_child(detail_panel)
	var detail_body := VBoxContainer.new()
	detail_body.add_theme_constant_override("separation", 8)
	detail_body.add_theme_constant_override("margin_left", 16)
	detail_body.add_theme_constant_override("margin_right", 16)
	detail_body.add_theme_constant_override("margin_top", 14)
	detail_body.add_theme_constant_override("margin_bottom", 14)
	detail_panel.add_child(detail_body)
	detail_body.add_child(_label("SELECTED SYSTEM", 10, ACCENT, true))
	selected_system_label = _label("Launch Port", 18, TEXT, true)
	detail_body.add_child(selected_system_label)
	selected_system_detail = _label("HOME · CURRENT LOCATION", 10, MUTED)
	detail_body.add_child(selected_system_detail)
	detail_body.add_child(_label("PLACE A MAP MARKER", 10, MUTED, true))
	var markers := HBoxContainer.new()
	markers.add_theme_constant_override("separation", 6)
	detail_body.add_child(markers)
	var sigil_colors := [Color("5df2e1"), Color("ff69c7"), Color("ffd166"), Color("b28cff"), Color("8cff9c"), Color("ff925e")]
	for marker_index in 6:
		var marker_button := _header_button("  ")
		marker_button.custom_minimum_size = Vector2(38, 36)
		marker_button.modulate = sigil_colors[marker_index]
		marker_button.tooltip_text = "Abstract sigil %d · assign your own meaning" % (marker_index + 1)
		marker_button.pressed.connect(_set_map_marker.bind(str(marker_index)))
		markers.add_child(marker_button)
	var clear_marker := _header_button("CLEAR")
	clear_marker.custom_minimum_size = Vector2(54, 36)
	clear_marker.pressed.connect(_set_map_marker.bind(""))
	markers.add_child(clear_marker)
	detail_body.add_child(_label("PLANETS IN THIS SYSTEM", 10, MUTED, true))
	route_list = VBoxContainer.new()
	route_list.add_theme_constant_override("separation", 7)
	side.add_child(route_list)
	_refresh_map()


func _on_map_system_selected(index: int) -> void:
	if index < 0 or index >= GalaxyMapView.SYSTEMS.size():
		return
	selected_system_label.text = GalaxyMapView.SYSTEMS[index].name
	selected_system_detail.text = "%d PLANETS · MARS COLONY%s" % [GalaxyMapView.SYSTEMS[index].planets.size(), " · CURRENT SYSTEM" if index == galaxy_map.current_index else ""]
	_refresh_map()


func _set_map_marker(marker: String) -> void:
	galaxy_map.set_marker(marker)
	var system_id: String = GalaxyMapView.SYSTEMS[galaxy_map.selected].id
	runtime.set_galaxy_marker(system_id, -1 if marker.is_empty() else int(marker))


func _build_orders_page() -> void:
	var page := _new_page("orders")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	page.add_child(column)
	column.add_child(_section_header("DELIVERY ORDERS", "Delivery target and cargo details · %s" % runtime.setup_status))
	var orders_panel := _panel()
	orders_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(orders_panel)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.add_theme_constant_override("margin_left", 24)
	body.add_theme_constant_override("margin_right", 24)
	body.add_theme_constant_override("margin_top", 24)
	body.add_theme_constant_override("margin_bottom", 24)
	orders_panel.add_child(body)
	mission_title_label = _label("", 18, TEXT, true)
	body.add_child(mission_title_label)
	mission_detail_label = _label("", 13, MUTED)
	mission_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(mission_detail_label)
	delivery_button = _header_button("CONFIRM DELIVERY")
	delivery_button.custom_minimum_size = Vector2(220, 48)
	delivery_button.pressed.connect(_confirm_delivery)
	body.add_child(delivery_button)
	_refresh_orders()


func _build_hub_page() -> void:
	var page := _new_page("hub")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	page.add_child(column)
	column.add_child(_section_header("PLANET HUB", "Delivery and inventory trade are the MVP hub services"))
	var services := HBoxContainer.new()
	services.add_theme_constant_override("separation", 16)
	services.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(services)
	var delivery_panel := _panel()
	delivery_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	services.add_child(delivery_panel)
	var delivery_body := VBoxContainer.new()
	delivery_body.add_theme_constant_override("separation", 12)
	delivery_body.add_theme_constant_override("margin_left", 20)
	delivery_body.add_theme_constant_override("margin_right", 20)
	delivery_body.add_theme_constant_override("margin_top", 20)
	delivery_body.add_theme_constant_override("margin_bottom", 20)
	delivery_panel.add_child(delivery_body)
	delivery_body.add_child(_label("DELIVERY DESK", 12, ACCENT, true))
	hub_location_label = _label("", 13, TEXT)
	delivery_body.add_child(hub_location_label)
	hub_credits_label = _label("", 12, MUTED)
	delivery_body.add_child(hub_credits_label)
	delivery_body.add_child(_label("Active mission cargo can be confirmed from Orders when you reach its destination.", 11, MUTED))
	var market_panel := _panel()
	market_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	services.add_child(market_panel)
	var market_body := VBoxContainer.new()
	market_body.add_theme_constant_override("separation", 12)
	market_body.add_theme_constant_override("margin_left", 20)
	market_body.add_theme_constant_override("margin_right", 20)
	market_body.add_theme_constant_override("margin_top", 20)
	market_body.add_theme_constant_override("margin_bottom", 20)
	market_panel.add_child(market_body)
	market_body.add_child(_label("BUY / SELL INVENTORY", 12, ACCENT, true))
	hub_market_list = VBoxContainer.new()
	hub_market_list.add_theme_constant_override("separation", 8)
	market_body.add_child(hub_market_list)
	_refresh_hub()


func _build_menu_page() -> void:
	var page := _new_page("menu")
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(center)
	var panel := _panel()
	panel.custom_minimum_size = Vector2(440, 560)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	content.add_theme_constant_override("margin_left", 38)
	content.add_theme_constant_override("margin_right", 38)
	content.add_theme_constant_override("margin_top", 34)
	content.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(content)
	content.add_child(_label("SPACE COURIER", 28, TEXT, true))
	content.add_child(_label("A small demo of travel, cargo and ship management", 12, MUTED))
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	content.add_child(spacer)
	content.add_child(_menu_button("NEW GAME", _confirm_new_game))
	content.add_child(_menu_button("CONTINUE", _continue_game))
	content.add_child(_menu_button("LOAD GAME", _open_load_page))
	content.add_child(_menu_button("SETTINGS", _open_settings))
	content.add_child(_menu_button("CREDITS", _open_credits))
	content.add_child(_menu_button("QUIT", _quit_game))
	var footer := _label("DEMO SCENARIO · PLACEHOLDER ARTWORK", 10, MUTED, true)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(footer)


func _build_settings_page() -> void:
	var page := _new_page("settings")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	page.add_child(column)
	var heading := HBoxContainer.new()
	heading.add_child(_label("SETTINGS", 20, TEXT, true))
	var heading_spacer := Control.new()
	heading_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(heading_spacer)
	var back := _header_button("BACK")
	back.pressed.connect(_return_from_settings)
	heading.add_child(back)
	column.add_child(heading)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var panel := _panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	content.add_theme_constant_override("margin_left", 28)
	content.add_theme_constant_override("margin_right", 28)
	content.add_theme_constant_override("margin_top", 24)
	content.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(content)
	content.add_child(_label("AUDIO", 12, ACCENT, true))
	settings_master_slider = _setting_slider(content, "Master volume", "master_volume")
	settings_music_slider = _setting_slider(content, "Music volume", "music_volume")
	settings_sfx_slider = _setting_slider(content, "Effects volume", "sfx_volume")
	content.add_child(_label("DISPLAY", 12, ACCENT, true))
	settings_resolution = OptionButton.new()
	for resolution in ["1280 × 720", "1440 × 900", "1920 × 1080"]:
		settings_resolution.add_item(resolution)
	settings_resolution.item_selected.connect(_on_resolution_selected)
	content.add_child(_setting_option("Window resolution", settings_resolution))
	settings_window_mode = OptionButton.new()
	for mode in ["Windowed", "Fullscreen", "Borderless"]:
		settings_window_mode.add_item(mode)
	settings_window_mode.item_selected.connect(_on_window_mode_selected)
	content.add_child(_setting_option("Display mode", settings_window_mode))
	content.add_child(_label("CONTROLS", 12, ACCENT, true))
	content.add_child(_label("Mouse: select and place items · R: rotate selected item · Escape: pause", 12, MUTED))
	_load_settings()


func _build_saves_page() -> void:
	var page := _new_page("saves")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	page.add_child(column)
	var heading := HBoxContainer.new()
	save_page_title = _label("LOAD GAME", 20, TEXT, true)
	heading.add_child(save_page_title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(spacer)
	var back := _header_button("BACK")
	back.pressed.connect(_return_from_saves)
	heading.add_child(back)
	column.add_child(heading)
	var panel := _panel()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(scroll)
	save_slots_list = VBoxContainer.new()
	save_slots_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_slots_list.add_theme_constant_override("separation", 12)
	scroll.add_child(save_slots_list)
	delete_dialog = ConfirmationDialog.new()
	delete_dialog.title = "Delete Save"
	delete_dialog.dialog_text = "Delete this save slot? This action cannot be undone."
	delete_dialog.confirmed.connect(_confirm_delete_save)
	add_child(delete_dialog)
	overwrite_dialog = ConfirmationDialog.new()
	overwrite_dialog.title = "Overwrite Save"
	overwrite_dialog.dialog_text = "Replace the saved data in this slot?"
	overwrite_dialog.confirmed.connect(_confirm_overwrite_save)
	add_child(overwrite_dialog)


func _build_credits_page() -> void:
	var page := _new_page("credits")
	var center := CenterContainer.new()
	page.add_child(center)
	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	center.add_child(content)
	content.add_child(_label("CREDITS", 24, TEXT, true))
	content.add_child(_label("Space Courier", 16, ACCENT, true))
	content.add_child(_label("A data-driven management game prototype.\nDemo content and placeholder artwork are temporary.", 12, MUTED))
	var back := _header_button("BACK TO MENU")
	back.pressed.connect(func(): _show_page("menu"))
	content.add_child(back)


func _build_pause_overlay() -> void:
	pause_overlay = PanelContainer.new()
	pause_overlay.set_anchors_preset(Control.PRESET_CENTER)
	pause_overlay.position = Vector2(-210, -230)
	pause_overlay.custom_minimum_size = Vector2(420, 460)
	pause_overlay.visible = false
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_overlay.add_theme_stylebox_override("panel", _style(PANEL, ACCENT, 10, 1))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	content.add_theme_constant_override("margin_left", 32)
	content.add_theme_constant_override("margin_right", 32)
	content.add_theme_constant_override("margin_top", 30)
	content.add_theme_constant_override("margin_bottom", 30)
	pause_overlay.add_child(content)
	content.add_child(_label("PAUSED", 22, TEXT, true))
	content.add_child(_menu_button("RESUME", _resume_game))
	content.add_child(_menu_button("SAVE GAME", func(): _open_save_page("pause_save")))
	content.add_child(_menu_button("SETTINGS", _open_settings))
	content.add_child(_menu_button("MAIN MENU", _return_to_main_menu))
	add_child(pause_overlay)


func _build_dialogs() -> void:
	new_game_dialog = ConfirmationDialog.new()
	new_game_dialog.title = "Start a New Game"
	new_game_dialog.dialog_text = "Start a new demo? The current autosave will be replaced. Manual save slots will remain."
	new_game_dialog.confirmed.connect(_start_new_game)
	add_child(new_game_dialog)


func _menu_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(340, 48)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_stylebox_override("normal", _style(PANEL_LIGHT, LINE, 6, 1))
	button.add_theme_stylebox_override("hover", _style(Color("20334b"), ACCENT, 6, 1))
	button.pressed.connect(callback)
	return button


func _setting_slider(parent: VBoxContainer, caption: String, key: String) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.add_child(_label(caption, 12, TEXT))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.custom_minimum_size.x = 300
	slider.value = 1.0
	slider.value_changed.connect(_on_audio_setting_changed.bind(key))
	row.add_child(slider)
	parent.add_child(row)
	return slider


func _setting_option(caption: String, option: OptionButton) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.add_child(_label(caption, 12, TEXT))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	option.custom_minimum_size.x = 300
	row.add_child(option)
	return row


func _load_settings() -> void:
	var config := ConfigFile.new()
	var result := config.load("user://space_courier_settings.cfg")
	var master := float(config.get_value("audio", "master", 0.8)) if result == OK else 0.8
	var music := float(config.get_value("audio", "music", 0.7)) if result == OK else 0.7
	var sfx := float(config.get_value("audio", "sfx", 0.8)) if result == OK else 0.8
	settings_master_slider.set_value_no_signal(master)
	settings_music_slider.set_value_no_signal(music)
	settings_sfx_slider.set_value_no_signal(sfx)
	_ensure_audio_bus("Music")
	_ensure_audio_bus("SFX")
	_apply_audio_bus("Master", master)
	_apply_audio_bus("Music", music)
	_apply_audio_bus("SFX", sfx)
	var resolution_index := int(config.get_value("display", "resolution", 1)) if result == OK else 1
	settings_resolution.select(clampi(resolution_index, 0, 2))
	var mode_index := int(config.get_value("display", "window_mode", 0)) if result == OK else 0
	settings_window_mode.select(clampi(mode_index, 0, 2))
	_apply_resolution(settings_resolution.selected)
	_apply_window_mode(settings_window_mode.selected)


func _on_audio_setting_changed(value: float, key: String) -> void:
	var bus_name := "Master"
	if key == "music_volume":
		bus_name = "Music"
	elif key == "sfx_volume":
		bus_name = "SFX"
	_ensure_audio_bus(bus_name)
	_apply_audio_bus(bus_name, value)
	var config := _load_config()
	config.set_value("audio", key.trim_suffix("_volume"), value)
	config.save("user://space_courier_settings.cfg")


func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, "Master")


func _apply_audio_bus(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var volume_db := -80.0 if value <= 0.001 else linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func _on_resolution_selected(index: int) -> void:
	_apply_resolution(index)
	var config := _load_config()
	config.set_value("display", "resolution", index)
	config.save("user://space_courier_settings.cfg")


func _apply_resolution(index: int) -> void:
	var sizes := [Vector2i(1280, 720), Vector2i(1440, 900), Vector2i(1920, 1080)]
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(sizes[clampi(index, 0, sizes.size() - 1)])


func _on_window_mode_selected(index: int) -> void:
	_apply_window_mode(index)
	var config := _load_config()
	config.set_value("display", "window_mode", index)
	config.save("user://space_courier_settings.cfg")


func _apply_window_mode(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_apply_resolution(settings_resolution.selected)
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func _load_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.load("user://space_courier_settings.cfg")
	return config


func _build_event_overlay() -> void:
	event_overlay = PanelContainer.new()
	event_overlay.set_anchors_preset(Control.PRESET_CENTER)
	event_overlay.position = Vector2(-250, -170)
	event_overlay.custom_minimum_size = Vector2(500, 340)
	event_overlay.visible = false
	event_overlay.add_theme_stylebox_override("panel", _style(PANEL, ACCENT, 10, 1))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	content.add_theme_constant_override("margin_left", 24)
	content.add_theme_constant_override("margin_right", 24)
	content.add_theme_constant_override("margin_top", 24)
	content.add_theme_constant_override("margin_bottom", 24)
	event_overlay.add_child(content)
	content.add_child(_label("TRAVEL EVENT", 12, ACCENT, true))
	event_question_label = _label("", 18, TEXT, true)
	event_question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(event_question_label)
	for index in 2:
		var choice := Button.new()
		choice.custom_minimum_size.y = 48
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice.focus_mode = Control.FOCUS_NONE
		choice.add_theme_color_override("font_color", TEXT)
		choice.add_theme_stylebox_override("normal", _style(PANEL_LIGHT, LINE, 5, 1))
		choice.add_theme_stylebox_override("hover", _style(Color("20334b"), ACCENT, 5, 1))
		choice.pressed.connect(_choose_event.bind(index))
		event_choice_buttons.append(choice)
		content.add_child(choice)
	add_child(event_overlay)


func _build_message_banner() -> void:
	message_banner = PanelContainer.new()
	message_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	message_banner.position = Vector2(-260, 142)
	message_banner.custom_minimum_size = Vector2(520, 56)
	message_banner.visible = false
	message_banner.add_theme_stylebox_override("panel", _style(PANEL_LIGHT, LINE, 7, 1))
	message_label = _label("", 12, TEXT)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_banner.add_child(_padded_control(message_label, 12, 8))
	add_child(message_banner)
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 6.0
	message_timer.timeout.connect(_hide_message)
	add_child(message_timer)


func _build_combat_overlay() -> void:
	combat_overlay = PanelContainer.new()
	combat_overlay.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	combat_overlay.position = Vector2(-245, -180)
	combat_overlay.custom_minimum_size = Vector2(490, 128)
	combat_overlay.visible = false
	combat_overlay.add_theme_stylebox_override("panel", _style(PANEL, Color("c46f79"), 8, 1))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.add_theme_constant_override("margin_left", 18)
	content.add_theme_constant_override("margin_right", 18)
	content.add_theme_constant_override("margin_top", 14)
	content.add_theme_constant_override("margin_bottom", 14)
	combat_overlay.add_child(content)
	content.add_child(_label("COMBAT · ROUTE CONTINUES", 11, Color("ff9e9e"), true))
	combat_status_label = _label("", 12, TEXT)
	content.add_child(combat_status_label)
	combat_special_button = _header_button("ACTIVATE SPECIAL EQUIPMENT")
	combat_special_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	combat_special_button.pressed.connect(_activate_special)
	content.add_child(combat_special_button)
	add_child(combat_overlay)


func _new_page(page_name: String) -> Control:
	var page := MarginContainer.new()
	page.name = page_name.capitalize()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("margin_left", 28)
	page.add_theme_constant_override("margin_right", 28)
	page.add_theme_constant_override("margin_top", 22)
	page.add_theme_constant_override("margin_bottom", 24)
	page.visible = false
	page_stack.add_child(page)
	return page


func _show_page(page_name: String) -> void:
	current_page = page_name
	for page in page_stack.get_children():
		page.visible = page.name.to_lower() == page_name
	for key in nav_buttons:
		var button: Button = nav_buttons[key]
		var active: bool = key == page_name
		button.add_theme_color_override("font_color", ACCENT if active else MUTED)
		button.add_theme_stylebox_override("normal", _style(PANEL_LIGHT if active else Color("0c1420"), LINE if active else Color("0c1420"), 5 if active else 0, 1 if active else 0))
	if page_name == "map" and runtime.is_configured and is_instance_valid(galaxy_map):
		var current_planet := runtime.catalog.get_definition("planet", runtime.session.current_planet_id) as PlanetDefinition
		if current_planet != null:
			for index in GalaxyMapView.SYSTEMS.size():
				if GalaxyMapView.SYSTEMS[index].id == current_planet.system_id:
					galaxy_map.selected = index
					_on_map_system_selected(index)
					break


func _status_chip(caption: String, value: String) -> Control:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", _style(PANEL_LIGHT, LINE, 5, 1))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	col.add_theme_constant_override("margin_left", 12)
	col.add_theme_constant_override("margin_right", 12)
	col.add_theme_constant_override("margin_top", 6)
	col.add_theme_constant_override("margin_bottom", 6)
	box.add_child(col)
	col.add_child(_label(caption, 9, MUTED, true))
	var value_label := _label(value, 12, TEXT, true)
	if caption == "TRAVEL":
		travel_status_value = value_label
	elif caption == "DESTINATION":
		destination_status_value = value_label
	elif caption == "SHIP":
		ship_status_value = value_label
	elif caption == "FOOD":
		food_status_value = value_label
	elif caption == "FUEL":
		fuel_status_value = value_label
	col.add_child(value_label)
	return box


func _header_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(76, 38)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_stylebox_override("normal", _style(PANEL_LIGHT, LINE, 5, 1))
	button.add_theme_stylebox_override("hover", _style(Color("20334b"), ACCENT, 5, 1))
	return button


func _refresh_status() -> void:
	if not is_instance_valid(travel_status_value):
		return
	if runtime.is_configured:
		travel_status_value.text = GameSession.TravelState.keys()[runtime.session.state].capitalize()
		var destination_id := runtime.session.current_planet_id
		if runtime.session.travel != null:
			destination_id = runtime.session.travel.destination_planet_id
		destination_status_value.text = String(destination_id)
		var ship: ShipDefinition = runtime.inventory.ship
		ship_status_value.text = ship.display_name if ship != null else "—"
		food_status_value.text = str(runtime.session.resources.get("food", "—"))
		fuel_status_value.text = str(runtime.session.resources.get("fuel", "—"))
	else:
		travel_status_value.text = "Setup required"
		destination_status_value.text = "Not configured"
		ship_status_value.text = "Not configured"
		food_status_value.text = "—"
		fuel_status_value.text = "—"
	if is_instance_valid(save_button):
		save_button.disabled = not runtime.is_configured
	if is_instance_valid(load_button):
		load_button.disabled = not runtime.is_configured
	if nav_buttons.has("hub"):
		var current_planet: PlanetDefinition
		if runtime.is_configured:
			current_planet = runtime.catalog.get_definition("planet", runtime.session.current_planet_id) as PlanetDefinition
		var at_civilization := current_planet != null and current_planet.civilization_present
		var hub_button: Button = nav_buttons["hub"]
		hub_button.disabled = not runtime.is_configured or not at_civilization or runtime.session.state != GameSession.TravelState.DOCKED
		if hub_button.disabled and current_page == "hub":
			_show_page("ship")
	if is_instance_valid(inventory_grid):
		inventory_grid.set_travelling(runtime.session.state in [GameSession.TravelState.TRAVELLING, GameSession.TravelState.EVENT_PAUSED])
		inventory_grid.queue_redraw()
		_refresh_inventory_count()
	if is_instance_valid(route_list):
		for child in route_list.get_children():
			child.queue_free()
		_refresh_map()
	_refresh_orders()
	_refresh_hub()


func _refresh_map() -> void:
	if not is_instance_valid(route_list):
		return
	for child in route_list.get_children():
		child.queue_free()
	if not runtime.is_configured:
		route_list.add_child(_placeholder("MAP DATA", runtime.setup_status))
		return
	var current_planet := runtime.catalog.get_definition("planet", runtime.session.current_planet_id) as PlanetDefinition
	var current_system_index := 0
	if current_planet != null:
		for index in GalaxyMapView.SYSTEMS.size():
			if GalaxyMapView.SYSTEMS[index].id == current_planet.system_id:
				current_system_index = index
				break
	galaxy_map.set_current(current_system_index)
	galaxy_map.load_markers(runtime.galaxy_markers)
	for world in GalaxyMapView.SYSTEMS[galaxy_map.selected].planets:
		var destination_id := StringName(world.id)
		var planet := runtime.catalog.get_definition("planet", destination_id) as PlanetDefinition
		if planet == null:
			continue
		var route: TravelDefinition
		if destination_id != runtime.session.current_planet_id:
			for value in runtime.catalog.get_all("travel"):
				var candidate := value as TravelDefinition
				if candidate != null and candidate.origin_planet_id == runtime.session.current_planet_id and candidate.destination_planet_id == destination_id:
					route = candidate
					break
		var quote: Dictionary = runtime.get_travel_quote(route.id) if route != null else {}
		var button := Button.new()
		var resource_text := ""
		if not planet.resource_notes.is_empty():
			resource_text = " · Resources: %s" % ", ".join(planet.resource_notes)
		var type_label := planet.world_type.to_upper()
		var action_text := "CURRENT LOCATION" if destination_id == runtime.session.current_planet_id else "%.0fs · FOOD %.1f · FUEL %.1f" % [quote.get("duration_seconds", 0.0), quote.get("food_cost", 0.0), quote.get("fuel_cost", 0.0)]
		button.text = "%s  ·  %s\n%s%s" % [planet.display_name, type_label, action_text, resource_text]
		button.custom_minimum_size.y = 66
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = destination_id == runtime.session.current_planet_id or runtime.session.state != GameSession.TravelState.DOCKED or route == null or not bool(quote.get("ok", false))
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_color_override("font_color", TEXT)
		button.add_theme_stylebox_override("normal", _style(PANEL_LIGHT, LINE, 6, 1))
		button.add_theme_stylebox_override("hover", _style(Color("20334b"), ACCENT, 6, 1))
		if destination_id != runtime.session.current_planet_id and quote.has("reason") and not String(quote.reason).is_empty():
			button.tooltip_text = String(quote.reason)
		if route != null:
			button.pressed.connect(_begin_travel.bind(route.id))
		route_list.add_child(button)


func _refresh_inventory_count() -> void:
	if is_instance_valid(inventory_count_label):
		inventory_count_label.text = "%d items" % runtime.inventory.items.size()


func _refresh_orders() -> void:
	if not is_instance_valid(mission_title_label):
		return
	if not runtime.is_configured or runtime.active_mission_id.is_empty():
		mission_title_label.text = "No active delivery"
		mission_detail_label.text = ""
		delivery_button.disabled = true
		return
	var mission := runtime.catalog.get_definition("mission", runtime.active_mission_id) as MissionDefinition
	if mission == null:
		mission_title_label.text = "Mission data unavailable"
		mission_detail_label.text = ""
		delivery_button.disabled = true
		return
	mission_title_label.text = mission.display_name
	var target := runtime.catalog.get_definition("planet", mission.delivery_target_planet_id) as PlanetDefinition
	var target_name := target.display_name if target != null else String(mission.delivery_target_planet_id)
	var cargo_lines := PackedStringArray()
	for requirement in mission.required_cargo:
		var item_id := StringName(requirement.get("definition_id", ""))
		var item := runtime.catalog.get_definition("item", item_id) as ItemDefinition
		var item_name := item.display_name if item != null else String(item_id)
		cargo_lines.append("%s × %d" % [item_name, int(requirement.get("quantity", 0))])
	var completion_text := "COMPLETED" if runtime.mission_completed else "ACTIVE"
	mission_detail_label.text = "%s · Deliver to %s\nRequired cargo: %s\nReward: %s credits" % [completion_text, target_name, ", ".join(cargo_lines), str(mission.reward_data.get("credits", 0))]
	delivery_button.disabled = runtime.mission_completed or runtime.session.current_planet_id != mission.delivery_target_planet_id or runtime.session.state != GameSession.TravelState.DOCKED


func _refresh_hub() -> void:
	if not is_instance_valid(hub_market_list):
		return
	for child in hub_market_list.get_children():
		child.queue_free()
	if not runtime.is_configured:
		hub_location_label.text = "Demo setup is loading."
		return
	var planet := runtime.catalog.get_definition("planet", runtime.session.current_planet_id) as PlanetDefinition
	if planet == null or not planet.civilization_present or runtime.session.state != GameSession.TravelState.DOCKED:
		hub_location_label.text = "Arrive at a civilization planet to trade."
		hub_credits_label.text = ""
		hub_market_list.add_child(_label("Market is unavailable here.", 11, MUTED))
		return
	hub_location_label.text = planet.display_name
	hub_credits_label.text = "Credits: %d · Reputation XP: %d" % [runtime.credits, runtime.reputation_xp]
	hub_market_list.add_child(_label("SHOP STOCK", 10, MUTED, true))
	for item_id in planet.market_item_ids:
		var definition := runtime.catalog.get_definition("item", item_id) as ItemDefinition
		if definition == null:
			continue
		var buy_button := _header_button("BUY  %s  ·  %d credits" % [definition.display_name, maxi(0, definition.buy_price)])
		buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_button.disabled = definition.buy_price < 0 or runtime.credits < definition.buy_price
		buy_button.pressed.connect(_buy_item.bind(item_id))
		hub_market_list.add_child(buy_button)
	hub_market_list.add_child(_label("CARGO ABOARD", 10, MUTED, true))
	var sellable_count := 0
	for instance in runtime.inventory.items:
		if instance == null or instance.delivered or instance.definition == null:
			continue
		sellable_count += 1
		var sell_button := _header_button("SELL  %s  ·  %d credits" % [instance.definition.display_name, maxi(0, instance.definition.sell_price)])
		sell_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sell_button.disabled = instance.definition.sell_price < 0
		if instance.definition.sell_reputation_delta < 0:
			sell_button.tooltip_text = "Selling reduces reputation by %d XP." % absi(instance.definition.sell_reputation_delta)
		sell_button.pressed.connect(_sell_item.bind(instance.instance_id))
		hub_market_list.add_child(sell_button)
	if sellable_count == 0:
		hub_market_list.add_child(_label("No items aboard.", 11, MUTED))


func _confirm_delivery() -> void:
	var result := runtime.deliver_active_mission()
	_show_message("Delivery completed." if result.ok else result.reason)


func _buy_item(item_id: StringName) -> void:
	var result := runtime.buy_market_item(item_id)
	_show_message(result.reason)


func _sell_item(instance_id: StringName) -> void:
	var result := runtime.sell_inventory_item(instance_id)
	_show_message(result.reason)


func _begin_travel(travel_id: StringName) -> void:
	var result := runtime.begin_travel(travel_id)
	if not result.ok:
		_show_message(result.reason)
	else:
		_show_message("Journey started. Food and fuel are being consumed in transit.")
	_refresh_status()


func _on_arrival(planet_id: StringName) -> void:
	var planet := runtime.catalog.get_definition("planet", planet_id) as PlanetDefinition
	if planet != null and is_instance_valid(galaxy_map):
		for index in GalaxyMapView.SYSTEMS.size():
			if GalaxyMapView.SYSTEMS[index].id == planet.system_id:
				galaxy_map.selected = index
				_on_map_system_selected(index)
				break
	if planet != null and planet.civilization_present:
		_show_message("Arrived at %s. Hub services are waiting for approved delivery and economy data." % planet.display_name)
	else:
		_show_message("Arrived at %s." % String(planet_id))


func _save_game() -> void:
	_open_save_page("game_save")


func _load_game() -> void:
	_open_save_page("game_load")


func _open_load_page() -> void:
	_open_save_page("menu_load")


func _open_save_page(source: String) -> void:
	if source.begins_with("game") or source.begins_with("pause"):
		if current_page in ["ship", "shipyard", "map", "orders", "hub"]:
			gameplay_return_page = current_page
	if get_tree().paused:
		get_tree().paused = false
		pause_overlay.visible = false
	event_overlay.visible = false
	save_page_mode = "save" if source == "game_save" or source == "pause_save" else "load"
	return_page = "game" if source.begins_with("game") or source.begins_with("pause") else "menu"
	runtime.gameplay_active = false
	_set_game_chrome(false)
	_show_page("saves")
	_refresh_save_slots()


func _refresh_save_slots() -> void:
	if not is_instance_valid(save_slots_list):
		return
	save_page_title.text = "SAVE GAME" if save_page_mode == "save" else "LOAD GAME"
	for child in save_slots_list.get_children():
		child.queue_free()
	for slot_index in range(0, GameRuntime.MANUAL_SAVE_SLOTS + 1):
		var info := runtime.get_save_slot_info(slot_index)
		var card := _panel()
		save_slots_list.add_child(card)
		var body := VBoxContainer.new()
		body.add_theme_constant_override("separation", 8)
		body.add_theme_constant_override("margin_left", 18)
		body.add_theme_constant_override("margin_right", 18)
		body.add_theme_constant_override("margin_top", 14)
		body.add_theme_constant_override("margin_bottom", 14)
		card.add_child(body)
		var title := "AUTOSAVE" if slot_index == 0 else "SAVE SLOT %d" % slot_index
		body.add_child(_label(title, 12, ACCENT, true))
		var details := "Empty slot"
		if info.exists:
			var planet := runtime.catalog.get_definition("planet", StringName(info.planet_id)) as PlanetDefinition
			var planet_name := planet.display_name if planet != null else String(info.planet_id)
			var mission_state := "Mission complete" if info.mission_completed else "Mission in progress"
			var playtime_minutes := int(float(info.get("playtime_seconds", 0.0)) / 60.0)
			details = "%s · %s · %d min · %d credits · %s" % [planet_name, info.saved_at, playtime_minutes, info.credits, mission_state]
		var detail_label := _label(details, 11, MUTED)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(detail_label)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 8)
		body.add_child(actions)
		if slot_index == 0:
			var autosave_note := _label("Automatically updated every five minutes", 10, MUTED)
			actions.add_child(autosave_note)
			if save_page_mode == "load":
				var load_auto := _header_button("LOAD")
				load_auto.disabled = not info.exists
				load_auto.pressed.connect(_choose_save_slot.bind(0))
				actions.add_child(load_auto)
		else:
			var action := _header_button("SAVE" if save_page_mode == "save" else "LOAD")
			action.disabled = save_page_mode == "load" and not info.exists
			action.pressed.connect(_choose_save_slot.bind(slot_index))
			actions.add_child(action)
			if info.exists:
				var delete := _header_button("DELETE")
				delete.pressed.connect(_ask_delete_save.bind(slot_index))
				actions.add_child(delete)


func _choose_save_slot(slot_index: int) -> void:
	if save_page_mode == "save":
		if runtime.get_save_slot_info(slot_index).exists:
			pending_save_slot = slot_index
			overwrite_dialog.dialog_text = "Replace the saved data in Save Slot %d?" % slot_index
			overwrite_dialog.popup_centered()
			return
		_perform_slot_save(slot_index)
		return
	var result: Dictionary
	if slot_index == 0:
		result = runtime.load_autosave()
	else:
		result = runtime.load_game(slot_index)
	if not result.ok:
		_show_message(result.reason)
		return
	if return_page == "menu":
		_enter_game()
	else:
		_enter_game(gameplay_return_page)


func _perform_slot_save(slot_index: int) -> void:
	var result := runtime.save_game(slot_index)
	pending_save_slot = -1
	if not result.ok:
		_show_message(result.reason)
		return
	_refresh_save_slots()
	_show_message("Game saved to Save Slot %d." % slot_index)


func _confirm_overwrite_save() -> void:
	if pending_save_slot > 0:
		_perform_slot_save(pending_save_slot)


func _ask_delete_save(slot_index: int) -> void:
	pending_delete_slot = slot_index
	delete_dialog.dialog_text = "Delete Save Slot %d? This action cannot be undone." % slot_index
	delete_dialog.popup_centered()


func _confirm_delete_save() -> void:
	var result := runtime.delete_save_slot(pending_delete_slot)
	pending_delete_slot = -1
	_refresh_save_slots()
	if not result.ok:
		_show_message(result.reason)


func _return_from_saves() -> void:
	if return_page == "game":
		_enter_game(gameplay_return_page)
	else:
		_set_game_chrome(false)
		_show_page("menu")


func _open_settings() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_overlay.visible = false
	settings_return_page = "game" if current_page in ["ship", "shipyard", "map", "orders", "hub"] else "menu"
	if settings_return_page == "game":
		gameplay_return_page = current_page
	event_overlay.visible = false
	runtime.gameplay_active = false
	_set_game_chrome(false)
	_show_page("settings")


func _return_from_settings() -> void:
	if settings_return_page == "game":
		_enter_game(gameplay_return_page)
	else:
		_set_game_chrome(false)
		_show_page("menu")


func _open_credits() -> void:
	_set_game_chrome(false)
	_show_page("credits")


func _continue_game() -> void:
	var result := runtime.continue_game()
	if not result.ok:
		_show_message(result.reason)
		return
	_enter_game()


func _confirm_new_game() -> void:
	new_game_dialog.popup_centered()


func _start_new_game() -> void:
	var result := runtime.start_new_game()
	if not result.ok:
		_show_message(result.reason)
		return
	_enter_game()


func _enter_game(page_name: String = "ship") -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	runtime.gameplay_active = true
	_set_game_chrome(true)
	_show_page(page_name)
	_refresh_status()
	event_overlay.visible = false
	if runtime.session.pending_event != null:
		_show_event(runtime.session.pending_event)


func _set_game_chrome(visible: bool) -> void:
	header_bar.visible = visible
	navigation_bar.visible = visible
	runtime.gameplay_active = visible


func _resume_game() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	event_overlay.visible = false
	runtime.gameplay_active = true
	if runtime.session.pending_event != null:
		_show_event(runtime.session.pending_event)


func _return_to_main_menu() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	event_overlay.visible = false
	runtime.save_autosave()
	runtime.gameplay_active = false
	_set_game_chrome(false)
	_show_page("menu")


func _quit_game() -> void:
	get_tree().quit()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE and runtime.gameplay_active:
		pause_overlay.visible = true
		runtime.gameplay_active = false
		get_tree().paused = true


func _show_event(event: EventDefinition) -> void:
	if event == null or event.choice_labels.size() != 2:
		return
	event_question_label.text = event.question
	for index in 2:
		event_choice_buttons[index].text = event.choice_labels[index]
	event_overlay.visible = true


func _show_combat() -> void:
	combat_overlay.visible = true
	_refresh_combat()


func _refresh_combat() -> void:
	if not is_instance_valid(combat_overlay):
		return
	if not runtime.combat.active:
		combat_overlay.visible = false
		return
	combat_overlay.visible = true
	combat_status_label.text = "%d threat(s) · attack ends in %.1f s" % [runtime.combat.enemies_remaining, runtime.combat.remaining_seconds()]
	combat_special_button.disabled = not runtime.combat.definition.special_equipment_can_resolve


func _activate_special() -> void:
	var result := runtime.activate_special_equipment()
	if not result.ok:
		_show_message(result.reason)


func _choose_event(choice_index: int) -> void:
	var result := runtime.choose_event(choice_index)
	if not result.ok:
		_show_message(result.reason)
		return
	event_overlay.visible = false


func _show_message(message: String) -> void:
	if not is_instance_valid(message_banner):
		return
	message_label.text = message
	message_banner.visible = true
	message_timer.start()


func _hide_message() -> void:
	if is_instance_valid(message_banner):
		message_banner.visible = false


func _section_header(title: String, subtitle: String) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.add_child(_label(title, 15, TEXT, true))
	col.add_child(_label(subtitle, 11, MUTED))
	return col


func _small_slot(title: String, detail: String) -> Control:
	var box := PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_stylebox_override("panel", _style(PANEL_LIGHT, LINE, 5, 1))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 5)
	col.add_theme_constant_override("margin_left", 14)
	col.add_theme_constant_override("margin_right", 14)
	col.add_theme_constant_override("margin_top", 12)
	col.add_theme_constant_override("margin_bottom", 12)
	box.add_child(col)
	col.add_child(_label(title, 10, ACCENT, true))
	col.add_child(_label(detail, 10, MUTED))
	return box


func _placeholder(title: String, detail: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color("0b1320"), LINE, 8, 1))
	var center := CenterContainer.new()
	center.add_theme_constant_override("margin_left", 18)
	center.add_theme_constant_override("margin_right", 18)
	center.add_theme_constant_override("margin_top", 18)
	center.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(center)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 8)
	center.add_child(col)
	col.add_child(_label(title, 13, MUTED, true))
	var desc := _label(detail, 11, MUTED)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(desc)
	return panel


func _panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 8, 1))
	return panel


func _padded_label(value: String, size: int, color: Color) -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 13)
	margin.add_theme_constant_override("margin_bottom", 13)
	var label := _label(value, size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(label)
	return margin


func _padded_control(child: Control, horizontal: int, vertical: int) -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", horizontal)
	margin.add_theme_constant_override("margin_right", horizontal)
	margin.add_theme_constant_override("margin_top", vertical)
	margin.add_theme_constant_override("margin_bottom", vertical)
	margin.add_child(child)
	return margin


func _label(value: String, size: int, color: Color, bold := false) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	return label


func _style(fill: Color, border: Color, radius: int, border_size: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_content_margin_all(10)
	style.set_border_width_all(border_size)
	style.set_corner_radius_all(radius)
	return style


class ShipyardSilhouette extends Control:
	var variant := 0
	var accent := Color("ff8a4c")
	const HULL := Color("e5e4dc")
	const SHADE := Color("8999a8")
	const INK := Color("263b51")
	const GLASS := Color("69b7c7")

	func _draw() -> void:
		var sx := size.x / 320.0
		var sy := size.y / 150.0
		draw_set_transform(Vector2((size.x - 320.0 * sx) * 0.5, (size.y - 150.0 * sy) * 0.5), 0.0, Vector2(sx, sy))
		var hull_points: PackedVector2Array
		var left_wing: PackedVector2Array
		var right_wing: PackedVector2Array
		if variant == 0:
			hull_points = PackedVector2Array([Vector2(67,72),Vector2(88,51),Vector2(223,51),Vector2(250,68),Vector2(236,91),Vector2(91,96),Vector2(67,84)])
			left_wing = PackedVector2Array([Vector2(83,68),Vector2(21,54),Vector2(29,79),Vector2(88,87)])
			right_wing = PackedVector2Array([Vector2(229,67),Vector2(294,53),Vector2(287,78),Vector2(234,88)])
		elif variant == 1:
			hull_points = PackedVector2Array([Vector2(54,74),Vector2(72,51),Vector2(249,50),Vector2(272,65),Vector2(258,94),Vector2(69,98),Vector2(49,85)])
			left_wing = PackedVector2Array([Vector2(71,67),Vector2(15,52),Vector2(21,85),Vector2(73,91)])
			right_wing = PackedVector2Array([Vector2(254,65),Vector2(307,51),Vector2(301,85),Vector2(258,91)])
		else:
			hull_points = PackedVector2Array([Vector2(43,73),Vector2(64,49),Vector2(270,49),Vector2(294,64),Vector2(279,96),Vector2(55,100),Vector2(35,85)])
			left_wing = PackedVector2Array([Vector2(61,66),Vector2(8,51),Vector2(15,87),Vector2(64,92)])
			right_wing = PackedVector2Array([Vector2(274,64),Vector2(312,51),Vector2(307,87),Vector2(280,92)])
		_draw_plate(left_wing, SHADE)
		_draw_plate(right_wing, SHADE)
		_draw_plate(hull_points, HULL)
		draw_colored_polygon(PackedVector2Array([Vector2(hull_points[1].x,82),Vector2(hull_points[5].x,89),Vector2(hull_points[4].x,88),Vector2(hull_points[3].x,78),Vector2(hull_points[2].x,79)]), SHADE)
		var orange := PackedVector2Array([Vector2(hull_points[2].x - 38,54),Vector2(hull_points[2].x - 10,54),Vector2(hull_points[3].x - 7,68),Vector2(hull_points[3].x - 15,77),Vector2(hull_points[2].x - 36,76)])
		draw_colored_polygon(orange, accent)
		var cockpit := PackedVector2Array([Vector2(119,59),Vector2(185,59),Vector2(197,67),Vector2(190,76),Vector2(119,75),Vector2(112,68)])
		draw_colored_polygon(cockpit, GLASS)
		_draw_outline(cockpit, INK, 2.0)
		var engine_positions := [83.0, 222.0] if variant == 0 else ([74.0, 244.0] if variant == 1 else [66.0, 253.0])
		for engine_x in engine_positions:
			draw_rect(Rect2(engine_x, 91, 25, 12), accent)
			draw_rect(Rect2(engine_x + 3, 94, 19, 3), Color("ffd18a"))
			draw_line(Vector2(engine_x,91), Vector2(engine_x+25,91), INK, 2)
		for x in range(0, hull_points.size()):
			var point: Vector2 = hull_points[x]
			if x > 0 and x % 2 == 0:
				draw_circle(point, 1.5, INK)
		draw_line(Vector2(27,121), Vector2(293,121), Color("31435a", 0.7), 1)
		draw_string(ThemeDB.fallback_font, Vector2(15,137), ["MU-01", "MU-04", "MU-09"][variant], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, accent)
		draw_string(ThemeDB.fallback_font, Vector2(305,137), "M.U.C.", HORIZONTAL_ALIGNMENT_RIGHT, -1, 8, SHADE)
		draw_set_transform(Vector2.ZERO)

	func _draw_plate(points: PackedVector2Array, fill: Color) -> void:
		draw_colored_polygon(points, fill)
		_draw_outline(points, INK, 2.0)

	func _draw_outline(points: PackedVector2Array, color: Color, width: float) -> void:
		var closed := points.duplicate()
		closed.append(points[0])
		draw_polyline(closed, color, width, true)
