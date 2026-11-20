extends Resource
class_name PlacementRule

## Rule names stay open-ended; the validator owns supported rule semantics.
@export var rule_type: StringName
@export var parameters: Dictionary = {}
