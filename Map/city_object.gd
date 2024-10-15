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
	CITY_BAR_SEED = 3,
	
	COUNT = 4
}

var rng_seed:int
var city_name : String
var short_city_name : String
var state_abbr : String
var population : int
var lat : float
var lon : float
var is_navigable : bool

func _init(dict: Dictionary):
	rng_seed = dict.seed
	city_name = dict.city_name
	short_city_name = dict.short_city_name
	state_abbr = dict.state_abbr
	is_navigable = dict.is_navigable
	population = dict.population
	lat = dict.lat
	lon = dict.lon
	
func getInternalSeed(channel: CITY_SEED) -> int:
	var rng = RandomNumberGenerator.new()
	rng.set_seed(rng_seed)
	for i in range(channel + 1):
		var s = rng.randi()
		if i == channel:
			return s
	return -1
	
func getBarName() -> String:
	var bar_seed = getInternalSeed(CITY_SEED.CITY_BAR_SEED)
	var rules = Dictionary()
	rules["bar_name"]= [
		"Joe's Bar and Grill",
		"Dan's Bar",
		"Emily's Bar"]
	var grammar = Tracery.Grammar.new(rules)
	var bar_rng = RandomNumberGenerator.new()
	bar_rng.set_seed(bar_seed)
	grammar.rng = bar_rng

	return grammar.flatten("#bar_name#")

func getPopulation() -> int:
	return population
