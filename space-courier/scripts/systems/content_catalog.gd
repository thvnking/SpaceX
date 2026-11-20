extends RefCounted
class_name ContentCatalog

const CONTENT_FOLDERS := {
	"item": "res://data/items",
	"ship": "res://data/ships",
	"planet": "res://data/planets",
	"travel": "res://data/travel",
	"event": "res://data/events",
	"combat": "res://data/combat",
	"mission": "res://data/missions",
}

var _definitions: Dictionary = {}


func load_all() -> Dictionary:
	_definitions.clear()
	for category in CONTENT_FOLDERS:
		var category_items: Dictionary = {}
		_definitions[category] = category_items
		_load_folder(String(category), CONTENT_FOLDERS[category], category_items)
	return {"ok": true, "reason": ""}


func get_definition(category: String, definition_id: StringName) -> Resource:
	return _definitions.get(category, {}).get(definition_id)


func get_all(category: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for definition in _definitions.get(category, {}).values():
		result.append(definition)
	return result


func is_empty(category: String) -> bool:
	return _definitions.get(category, {}).is_empty()


func register_definition(category: String, resource: Resource) -> void:
	if not _definitions.has(category):
		_definitions[category] = {}
	if resource == null:
		return
	var definition_id := StringName(str(resource.get("id")))
	if definition_id.is_empty():
		return
	_definitions[category][definition_id] = resource


func _load_folder(category: String, folder_path: String, output: Dictionary) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(folder_path)):
		return
	var directory := DirAccess.open(folder_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if directory.current_is_dir():
			if not file_name.begins_with("."):
				_load_folder(category, folder_path.path_join(file_name), output)
		elif file_name.get_extension().to_lower() in ["tres", "res"]:
			_register_resource(category, folder_path.path_join(file_name), output)
		file_name = directory.get_next()
	directory.list_dir_end()


func _register_resource(category: String, resource_path: String, output: Dictionary) -> void:
	var resource := ResourceLoader.load(resource_path)
	if resource == null:
		push_warning("Could not load content resource: %s" % resource_path)
		return
	var definition_id: StringName
	for property in resource.get_property_list():
		if property.get("name", "") == "id":
			definition_id = StringName(str(resource.get("id")))
			break
	if definition_id.is_empty():
		push_warning("Content resource has no id: %s" % resource_path)
		return
	if output.has(definition_id):
		push_warning("Duplicate %s id '%s': %s" % [category, definition_id, resource_path])
		return
	output[definition_id] = resource
