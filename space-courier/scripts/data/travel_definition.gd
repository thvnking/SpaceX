extends Resource
class_name TravelDefinition

## Numeric values stay unset until they are approved as game data.
@export var id: StringName
@export var origin_planet_id: StringName
@export var destination_planet_id: StringName
@export var segment_durations_seconds: Array[float] = []
@export var resource_drain_per_second: Dictionary = {}
## Keys are zero-based segment indices; each listed event interrupts that segment.
@export var segment_events: Dictionary = {}
## Keys are zero-based segment indices; combat does not pause the route.
@export var segment_combats: Dictionary = {}


func is_valid_definition() -> bool:
	if id.is_empty() or origin_planet_id.is_empty() or destination_planet_id.is_empty() or segment_durations_seconds.is_empty():
		return false
	for duration in segment_durations_seconds:
		if not is_finite(duration) or duration <= 0.0:
			return false
	for rate in resource_drain_per_second.values():
		if typeof(rate) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(rate)) or float(rate) < 0.0:
			return false
	for segment_index in segment_events:
		if int(segment_index) < 0 or int(segment_index) >= segment_durations_seconds.size():
			return false
		if segment_events[segment_index] == null or not segment_events[segment_index].is_valid_definition():
			return false
	for segment_index in segment_combats:
		if int(segment_index) < 0 or int(segment_index) >= segment_durations_seconds.size() or StringName(segment_combats[segment_index]).is_empty():
			return false
	return true
