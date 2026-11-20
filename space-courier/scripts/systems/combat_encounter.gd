extends RefCounted
class_name CombatEncounter

signal resolved(won_by: StringName)
signal started

var definition: CombatDefinition
var active := false
var elapsed_seconds := 0.0
var enemies_remaining := 0


func begin(encounter: CombatDefinition) -> Dictionary:
	if active:
		return _failure("An encounter is already active.")
	if encounter == null or not encounter.is_valid_definition():
		return _failure("Combat data is incomplete.")
	definition = encounter
	elapsed_seconds = 0.0
	enemies_remaining = encounter.starting_enemy_count
	active = true
	started.emit()
	if enemies_remaining == 0:
		_resolve(&"eliminate_enemies")
	return {"ok": true, "reason": ""}


func tick(delta: float) -> void:
	if not active:
		return
	elapsed_seconds += maxf(delta, 0.0)
	if elapsed_seconds >= definition.attack_duration_seconds:
		_resolve(&"survive_timer")


func enemy_defeated() -> void:
	if not active:
		return
	enemies_remaining = maxi(0, enemies_remaining - 1)
	if enemies_remaining == 0:
		_resolve(&"eliminate_enemies")


func activate_special_equipment() -> Dictionary:
	if not active:
		return _failure("No encounter is active.")
	if not definition.special_equipment_can_resolve:
		return _failure("This encounter has no configured special equipment solution.")
	_resolve(&"special_equipment")
	return {"ok": true, "reason": ""}


func remaining_seconds() -> float:
	if not active or definition == null:
		return 0.0
	return maxf(0.0, definition.attack_duration_seconds - elapsed_seconds)


func _resolve(method: StringName) -> void:
	active = false
	resolved.emit(method)


func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
