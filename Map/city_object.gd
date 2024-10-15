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
	CITY_ARENA_NAME_SEED = 4, # is this how I'm doing it?
	CITY_RACETRACK_NAME_SEED = 5,
	
	COUNT = 6
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
		"Emily's Bar",
		"Foo's Bar and Swill"]
	var grammar = Tracery.Grammar.new(rules)
	var bar_rng = RandomNumberGenerator.new()
	bar_rng.set_seed(bar_seed)
	grammar.rng = bar_rng

	return grammar.flatten("#bar_name#")

func getArenaName() -> String:
	var arena_name_seed = getInternalSeed(CITY_SEED.CITY_ARENA_NAME_SEED)
	var rules = Dictionary()
	rules["arena_name"]= [
		city_name + " Arena",
		city_name + " Pro/Am Arena",
		"Memorial Arena",
		"Mega Arena",
		city_name + " Municipal Arena"]
	var grammar = Tracery.Grammar.new(rules)
	var arena_rng = RandomNumberGenerator.new()
	arena_rng.set_seed(arena_name_seed)
	grammar.rng = arena_rng

	return grammar.flatten("#arena_name#")

func getRaceTrackName() -> String:
	var track_name_seed = getInternalSeed(CITY_SEED.CITY_RACETRACK_NAME_SEED)
	var rules = Dictionary()
	rules["track_name"]= [
		city_name + " Racetrack",
		city_name + " Track",
		"Memorial Track",
		"Mega Track",
		city_name + " Municipal Motorsport Facility"]
	var grammar = Tracery.Grammar.new(rules)
	var track_rng = RandomNumberGenerator.new()
	track_rng.set_seed(track_name_seed)
	grammar.rng = track_rng

	return grammar.flatten("#track_name#")


func getPopulation() -> int:
	return population
