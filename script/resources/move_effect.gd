@tool
extends Resource
class_name MoveEffect

enum Target {NONE, TARGET, SELF, ALL}
enum Source {FIXED, USER_MAX_HP, USER_CURRENT_HP, USER_LEVEL, TARGET_MAX_HP, TARGET_CURRENT_HP, TARGET_LEVEL, DAMAGE}

@export var effect : Enums.MoveEffect:
	set(value):
		effect = value
		notify_property_list_changed()
@export var strike_chances : Array[float]
@export var multiplier : float
@export var target : Target
@export var status : Enums.NonVolatileStatus
@export_range(0.0, 1.0) var chance : float
@export var overwrite : bool
@export var factors : Array[int]
@export var moves_to_bypass : Array[Enums.Moves]
@export var power : int
@export var duration : int
@export var invulnerable : bool
@export var immobile : bool
@export var duration_range : Array[int]
@export var source : Source

func _validate_property(property: Dictionary):
	if property.name != "effect":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if effect == Enums.MoveEffect.MULTIHIT and property.name in ["strike_chances"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Enums.MoveEffect.SCATTER_COINS and property.name in ["multiplier"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Enums.MoveEffect.INFLICT_STATUS and property.name in ["chance", "status", "target", "overwrite"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Enums.MoveEffect.CHANGE_STAT and property.name in ["chance", "factors", "target"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Enums.MoveEffect.HIT_INVULNERABLE and property.name in ["moves_to_bypass"]:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif effect == Enums.MoveEffect.BYPASS_MINIMIZE and property.name in ["multiplier"]:
		property.usage = PROPERTY_USAGE_DEFAULT
