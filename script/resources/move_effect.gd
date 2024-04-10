@tool
extends Resource
class_name MoveEffect

enum Effect {NO_EFFECT, INCREASED_CRIT, MULTIHIT, SCATTER_COINS, INFLICT_STATUS, SPECIAL_ACCURACY, ONE_HIT_KO, CHANGE_STAT, HIT_INVULNERABLE, EXTENDED_RANGE, SWITCH_OPPONENT, CHARGE, TRAPPING, SPECIAL_DAMAGE, CAUSE_FLINCH, BYPASS_MINIMIZE, CRASH_DAMAGE, RECOIL}
enum Target {NONE, TARGET, SELF, ALL}
enum Source {FIXED, USER_MAX_HP, USER_CURRENT_HP, USER_LEVEL, TARGET_MAX_HP, TARGET_CURRENT_HP, TARGET_LEVEL, DAMAGE}

@export var effect : Effect:
	set(value):
		effect = value
		notify_property_list_changed()
@export var strike_chances : Array[float]
@export var multiplier : float
@export var target : Target
@export var status : Statuses.Status
@export_range(0.0, 1.0) var chance : float
@export var overwrite : bool
@export var factors : Array[int]
@export var moves_to_bypass : Array[int]
@export var power : int
@export var duration : int
@export var invulnerable : bool
@export var immobile : bool
@export var duration_range : Array[int]
@export var source : Source

func _validate_property(property: Dictionary):
	if property.name != "effect":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if effect == Effect.MULTIHIT and property.name in ["strike_chances"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Effect.SCATTER_COINS and property.name in ["multiplier"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Effect.INFLICT_STATUS and property.name in ["chance", "status", "target", "overwrite"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Effect.CHANGE_STAT and property.name in ["chance", "factors", "target"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Effect.HIT_INVULNERABLE and property.name in ["moves_to_bypass"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Effect.BYPASS_MINIMIZE and property.name in ["multiplier"]:
		property.usage = PROPERTY_USAGE_DEFAULT
