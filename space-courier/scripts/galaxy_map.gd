extends Control
class_name GalaxyMapView

signal system_selected(index: int)

const SYSTEMS := [
	{"id":"system_01", "name": "Orison", "pos": Vector2(0.48, 0.51), "planets": [{"id":"demo_origin", "name":"Launch Port", "type":"Civilization", "resources":[]}, {"id":"orison_outer", "name":"Pallas Reach", "type":"Colony", "resources":[]}]},
	{"id":"system_02", "name": "Veyra", "pos": Vector2(0.59, 0.42), "planets": [{"id":"demo_relay", "name":"Waystation", "type":"Colony", "resources":[]}, {"id":"veyra_mine", "name":"Cobalt Shelf", "type":"Extraction", "resources":["Cobalt", "Nickel"]}]},
	{"id":"system_03", "name": "Serein", "pos": Vector2(0.68, 0.32), "planets": [{"id":"serein_colony", "name":"Lumen", "type":"Colony", "resources":[]}, {"id":"serein_mine", "name":"Orrery-3", "type":"Extraction", "resources":["Silicates"]}]},
	{"id":"system_04", "name": "Caldera", "pos": Vector2(0.38, 0.39), "planets": [{"id":"demo_destination", "name":"Harbor Station", "type":"Civilization", "resources":[]}, {"id":"caldera_outer", "name":"Redoubt", "type":"Colony", "resources":[]}]},
	{"id":"system_05", "name": "Morrow", "pos": Vector2(0.30, 0.57), "planets": [{"id":"morrow_colony", "name":"Morrow Haven", "type":"Colony", "resources":[]}, {"id":"morrow_mine", "name":"The Shards", "type":"Extraction", "resources":["Iron", "Rare earths"]}]},
	{"id":"system_06", "name": "Ilyon", "pos": Vector2(0.42, 0.70), "planets": [{"id":"ilyon_colony", "name":"Sable", "type":"Colony", "resources":[]}, {"id":"ilyon_mine", "name":"Vesper Quarry", "type":"Extraction", "resources":["Titanium"]}]},
	{"id":"system_07", "name": "Aster", "pos": Vector2(0.61, 0.64), "planets": [{"id":"aster_civ", "name":"Aster Commons", "type":"Civilization", "resources":[]}, {"id":"aster_mine", "name":"Verdant Moon", "type":"Extraction", "resources":["Bio-gel"]}]},
	{"id":"system_08", "name": "Nacre", "pos": Vector2(0.76, 0.50), "planets": [{"id":"nacre_colony", "name":"Nacre One", "type":"Colony", "resources":[]}, {"id":"nacre_mine", "name":"Deepwell", "type":"Extraction", "resources":["Helium-3"]}]},
	{"id":"system_09", "name": "Cinder", "pos": Vector2(0.79, 0.72), "planets": [{"id":"cinder_civ", "name":"Cinderfall", "type":"Civilization", "resources":[]}, {"id":"cinder_outer", "name":"Ashline", "type":"Colony", "resources":[]}]},
	{"id":"system_10", "name": "Pelagos", "pos": Vector2(0.22, 0.35), "planets": [{"id":"pelagos_colony", "name":"Pelagos Station", "type":"Colony", "resources":[]}, {"id":"pelagos_mine", "name":"Blue Vault", "type":"Extraction", "resources":["Water ice"]}]},
]
const SIGIL_COLORS := [Color("5df2e1"), Color("ff69c7"), Color("ffd166"), Color("b28cff"), Color("8cff9c"), Color("ff925e")]
var zoom := 1.0
var offset := Vector2.ZERO
var selected := 0
var current_index := 0
var marker_types := {}
var dragging := false
var drag_origin := Vector2.ZERO
var offset_origin := Vector2.ZERO
var dust: Array[Vector2] = []

func _ready() -> void:
	custom_minimum_size = Vector2(500, 380)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for i in 300:
		dust.append(Vector2(fposmod(i * 0.618, 1.0), fposmod(i * 0.754877, 1.0)))

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color("08111d"), true)
	for i in range(12):
		var x := size.x * float(i) / 12.0
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.35, 0.55, 0.7, 0.045), 1.0)
	for i in range(8):
		var y := size.y * float(i) / 8.0
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.35, 0.55, 0.7, 0.045), 1.0)
	for i in dust.size():
		var p := _map_pos(dust[i])
		if rect.has_point(p):
			draw_circle(p, 0.7 + float(i % 3) * 0.35, Color(0.65, 0.77, 0.9, 0.22))
	# Soft galactic arm curves create a readable sector rather than a flat grid.
	for arm in 3:
		var points := PackedVector2Array()
		for step in 100:
			var t := float(step) / 99.0
			var a := t * 5.0 + float(arm) * TAU / 3.0
			var r := 0.03 + t * 0.42
			points.append(_map_pos(Vector2(0.5 + cos(a) * r, 0.5 + sin(a) * r * 0.72)))
		draw_polyline(points, Color(0.25, 0.61, 0.72, 0.11), 13.0 * zoom, true)
	for a in SYSTEMS.size():
		for b in range(a + 1, SYSTEMS.size()):
			if (a * 7 + b * 3) % 5 == 0:
				draw_line(_system_pos(a), _system_pos(b), Color(0.31, 0.56, 0.68, 0.16), 1.0)
	for i in SYSTEMS.size():
		var p := _system_pos(i)
		var has_civilization := false
		for body in SYSTEMS[i].planets:
			if body.type == "Civilization":
				has_civilization = true
		var color := Color("85b9ff") if has_civilization else Color("9aabc0")
		if i == current_index:
			draw_arc(p, 15.0, 0, TAU, 40, Color("73e2ce"), 1.4)
		if i == selected:
			draw_arc(p, 21.0, 0, TAU, 40, Color(0.48, 0.88, 0.81, 0.68), 1.0)
		draw_circle(p, 6.0, Color(color, 0.16))
		draw_circle(p, 3.6, color)
		var marker_key: String = String(SYSTEMS[i].id)
		if marker_types.has(marker_key):
			_draw_sigil(p + Vector2(15, -12), int(marker_types[marker_key]))
		draw_string(ThemeDB.fallback_font, p + Vector2(12, 4), SYSTEMS[i].name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12 if i == selected else 10, Color("e5edf6") if i == selected else Color("9eafc4"))
	if zoom >= 1.7:
		var focus := _system_pos(selected)
		var orbit_scale := clampf((zoom - 1.35) * 20.0, 7.0, 34.0)
		draw_circle(focus, 5.0, Color("fff1c4"))
		var orbit_count: int = SYSTEMS[selected].planets.size()
		for orbit in orbit_count:
			var radius := orbit_scale * float(orbit + 1)
			draw_arc(focus, radius, 0, TAU, 64, Color(0.52, 0.74, 0.88, 0.33), 1.0)
			var angle := float(orbit) * 1.7 + 0.5
			var planet := focus + Vector2(cos(angle), sin(angle) * 0.72) * radius
			var world_type: String = SYSTEMS[selected].planets[orbit].type
			var world_color := Color("89c3ff") if world_type == "Civilization" else Color("e1bd82") if world_type == "Colony" else Color("b994e8")
			draw_circle(planet, 3.0, world_color)
		draw_string(ThemeDB.fallback_font, focus + Vector2(12, orbit_scale * 4.0 + 15.0), "SYSTEM VIEW  ·  %s" % SYSTEMS[selected].name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("a9c2d4"))
	draw_string(ThemeDB.fallback_font, Vector2(18, size.y - 18), "SECTOR 07  /  10 SYSTEMS CHARTED", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("71869e"))

func _map_pos(normalized: Vector2) -> Vector2:
	return size * 0.5 + (normalized - Vector2(0.5, 0.5)) * size * zoom + offset

func _system_pos(index: int) -> Vector2:
	return _map_pos(SYSTEMS[index].pos)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = clampf(zoom * 1.18, 0.75, 3.2)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = clampf(zoom / 1.18, 0.75, 3.2)
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_origin = event.position
				offset_origin = offset
				dragging = true
			else:
				if dragging and event.position.distance_to(drag_origin) < 6.0:
					var nearest := -1
					var distance := 26.0
					for i in SYSTEMS.size():
						var d: float = event.position.distance_to(_system_pos(i))
						if d < distance:
							distance = d
							nearest = i
					if nearest >= 0:
						selected = nearest
						system_selected.emit(selected)
						queue_redraw()
				dragging = false
			accept_event()
	elif event is InputEventMouseMotion and dragging:
		offset = offset_origin + event.position - drag_origin
		queue_redraw()

func set_current(index: int) -> void:
	current_index = index
	queue_redraw()

func set_marker(marker: String) -> void:
	var marker_key: String = String(SYSTEMS[selected].id)
	if marker.is_empty():
		marker_types.erase(marker_key)
	else:
		marker_types[marker_key] = int(marker)
	queue_redraw()

func load_markers(markers: Dictionary) -> void:
	marker_types = markers.duplicate(true)
	queue_redraw()


func reset_view() -> void:
	zoom = 1.0
	offset = Vector2.ZERO
	queue_redraw()

func _draw_sigil(center: Vector2, index: int) -> void:
	var color: Color = SIGIL_COLORS[posmod(index, SIGIL_COLORS.size())]
	var r := 6.0
	match posmod(index, 6):
		0: # Offset arcs
			draw_arc(center + Vector2(-2, 0), r, -2.5, 1.9, 24, color, 1.5)
			draw_arc(center + Vector2(2, 0), r, 0.7, 5.1, 24, color, 1.5)
		1: # Displaced nodes
			draw_circle(center + Vector2(-4, -2), 1.5, color)
			draw_circle(center + Vector2(3, -3), 1.2, color)
			draw_circle(center + Vector2(1, 4), 1.8, color)
		2: # Broken crossing lines
			draw_line(center + Vector2(-6, -3), center + Vector2(-1, 1), color, 1.5)
			draw_line(center + Vector2(1, -1), center + Vector2(6, 3), color, 1.5)
			draw_line(center + Vector2(-2, 5), center + Vector2(3, -5), color, 1.5)
		3: # Uneven diamond loops
			draw_colored_polygon(PackedVector2Array([center + Vector2(0,-7), center + Vector2(5,-1), center + Vector2(2,6), center + Vector2(-5,3)]), color, PackedVector2Array())
			draw_colored_polygon(PackedVector2Array([center + Vector2(0,-4), center + Vector2(3,-1), center + Vector2(1,3), center + Vector2(-3,1)]), Color("08111d"), PackedVector2Array())
		4: # Offset orbital ellipse
			draw_arc(center, r, 0.2, 5.7, 32, color, 1.4)
			draw_circle(center + Vector2(5, -2), 1.6, color)
		5: # Asymmetric rays
			for ray in 5:
				var a := float(ray) * TAU / 5.0 + 0.2
				draw_line(center + Vector2(cos(a), sin(a)) * 2.0, center + Vector2(cos(a), sin(a)) * (5.0 + float(ray % 2)), color, 1.3)
