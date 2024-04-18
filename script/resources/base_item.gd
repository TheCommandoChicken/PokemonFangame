extends Resource
class_name BaseItem

@export var id : Enums.Items
@export var buy_price : int
@export var sell_price : int
@export var pocket : Enums.Pocket
@export var use : Enums.Scenario
@export var effects : Array[ItemEffect]
