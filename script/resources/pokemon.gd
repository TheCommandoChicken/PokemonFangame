extends Resource
class_name Pokemon

enum Gender {NONE, MALE, FEMALE}

@export var base : BasePokemon
@export var nickname : String
@export var shiny : bool
@export var gender : Gender
@export var original_trainer : String
@export var exp : int
@export var level : int
@export var friendship : int
@export var affection : int
@export var ability : Abilities.Ability
@export var nature : Natures.Nature
@export var pokeball : Pokeballs.Pokeball
@export var region : int
@export var route : int
@export var fateful : bool
@export var moves : Array
@export var status : Array
@export var stats = {
	"max_hp": 0,
	"current_hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export var ivs = {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export var evs = {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export var stages = {
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0,
	"eva": 0,
	"acc": 0,
	"crt": 0
}
@export var invulnerable : bool
@export var last_move : int
