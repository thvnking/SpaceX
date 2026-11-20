extends Resource
class_name EventDefinition

@export var id: StringName
@export_enum("assistant", "crew") var prompt_source: String = "assistant"
@export_multiline var question: String
@export var choice_labels: PackedStringArray = []
@export var choice_effects: Array[Dictionary] = []


func is_valid_definition() -> bool:
	if id.is_empty() or question.strip_edges().is_empty() or choice_labels.size() != 2 or choice_effects.size() != 2:
		return false
	for effect in choice_effects:
		var deltas: Variant = effect.get("resource_delta", {})
		if typeof(deltas) != TYPE_DICTIONARY:
			return false
		for amount in deltas.values():
			if typeof(amount) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(amount)):
				return false
	return true
