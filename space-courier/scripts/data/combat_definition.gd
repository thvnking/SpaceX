extends Resource
class_name CombatDefinition

@export var id: StringName
@export var attack_duration_seconds: float = -1.0
@export var starting_enemy_count: int = -1
@export var special_equipment_can_resolve: bool = false


func is_valid_definition() -> bool:
	return not id.is_empty() and is_finite(attack_duration_seconds) and attack_duration_seconds > 0.0 and starting_enemy_count >= 0
