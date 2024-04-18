@tool
extends Resource
class_name ItemEffect

enum Effect {NONE, HEAL, CATCH}

@export var effect : Effect:
	set(value):
		effect = value
		notify_property_list_changed()
@export var catch_rate : float

func catch_modifier():
	pass
