extends BaseButton

@export var pp_bar : TextureProgressBar
@export var max_pp_label : Label
@export var current_pp_label : Label
@export var move_name_label : Label
@export var type_icon : TextureRect
@export var background : TextureRect
@export var assigned_move : int
@export var pokemon : Pokemon
@export var type : Types.Type

func _ready():
	pass

func assign_move(user : Pokemon, move : Enums.Moves) -> void:
	move_name_label.text = TextManager.get_move_name(str(move), Settings.current_language)
	assigned_move = move
	type = load(DataManager.load_move(move)).type
	type_icon.texture = load("res://assets/battle/ui/move_button_icon_" + Types.Type.keys()[type] + ".png")
	background.texture = load("res://assets/battle/ui/move_button_base_" + Types.Type.keys()[type] + ".png")
	pokemon = user
	update_info()

func update_info() -> void:
	print(DataManager.load_move(assigned_move))
	var move = load(DataManager.load_move(assigned_move))
	max_pp_label.text = str(move.max_pp)
	current_pp_label.text = str(pokemon.current_pp[str(assigned_move)])
	pp_bar.value = roundi((float(pokemon.current_pp[str(assigned_move)])/float(move.max_pp)) * 48)
	if pokemon.current_pp[str(assigned_move)] == 0:
		disabled = true
	else:
		disabled = false

func _on_disable():
	disabled = true
	
func _on_enable():
	disabled = false

func _pressed():
	emit_signal("pressed", assigned_move, self)
