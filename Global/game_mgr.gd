extends Node
class_name GameMgr

@export var cur_city_short_name: String
@export var cur_state_abbr: String

enum ArenaResult {
	RESULT_WIN,
	RESULT_LOSS,
	RESULT_ESCAPE,
	RESULT_UNKNOWN,
	RESULT_COUNT
}

@export var last_arena_result:ArenaResult

func getTimeNow() -> float:
	return Time.get_ticks_msec()/ 1000.0
