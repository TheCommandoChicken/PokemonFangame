extends Resource
class_name BasePokemon

## Stores the two types of the Pokemon. Must always have a size of 2.
@export var types : Array[Types.types]
## The base stats of the Pokemon.
@export var base_stats = {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
	}
@export var catch_rate : int
@export var exp_yield : int
@export var ev_yield = {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export var abilities : Array[Abilities.Ability]
@export var hidden_ability : Abilities.Ability
@export var leveling_group : String
@export var base_friendship : int
@export var nat_dex : int
@export var reg_dex : int
@export var new_dex : int
@export var height : float
@export var weight : float
@export var gender_ratio : int
@export var egg_groups : Array
@export var egg_cycles : int
@export var leveling_learnset : Dictionary
