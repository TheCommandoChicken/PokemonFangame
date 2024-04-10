extends Resource
class_name Move

enum Category {PHYSICAL, SPECIAL, STATUS}

@export var id : int
@export var category : Category
@export var type : Types.Type
@export var power : int
@export_range(0.0, 1.0) var accuracy : float
@export_range(1, 64) var max_pp : int
@export var contact : bool
@export_range(-6, 6) var priority : int
@export var effects : Array
