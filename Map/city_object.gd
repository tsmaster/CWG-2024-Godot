extends Node
class_name CityObject

"""
This object should be the source of truth for city information
"""

enum CITY_SEED
{
	CITY_RACETRACK_SEED = 0,
	CITY_ARENA_SEED = 1,
	CITY_BUILDING_SEED = 2,	
	
	COUNT = 3
}

var seed:int

func _init(_seed: int):
	seed = _seed
	
func getInternalSeed(_seed: int, channel: CITY_SEED) -> int:
	var rng = RandomNumberGenerator.new()
	rng.set_seed(_seed)
	for i in range(channel + 1):
		var s = rng.randi()
		if i == channel:
			return s
	return -1
	
