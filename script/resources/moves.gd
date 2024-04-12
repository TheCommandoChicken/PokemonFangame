@tool
extends Resource
class_name Move

@export var id : int
@export var category := Enums.Category.PHYSICAL:
	set(value):
		category = value
		notify_property_list_changed()
@export var type : Types.Type
@export var power : int
@export_range(0.0, 1.0) var accuracy : float
@export_range(1, 64) var max_pp : int
@export var contact : bool
@export_range(-6, 6) var priority : int
@export var effects : Array[MoveEffect]

func _validate_property(property: Dictionary):
	if property.name in ["power", "accuracy"] and category == Enums.Category.STATUS:
		property.usage = PROPERTY_USAGE_NO_EDITOR
