extends BaseButton

@export var pp_bar : TextureProgressBar
@export var max_pp_label : Label
@export var current_pp_label : Label
@export var move_name_label : Label
@export var type_icon : TextureRect
@export var background : TextureRect
@export var assigned_move : int
@export var pokemon : Pokemon

func assign_move(user : Pokemon, move : int) -> void:
	move_name_label.text = TextManager.get_move_name(str(user.moves[move].id), Settings.current_language)
	assigned_move = move
	pokemon = user
	update_info()

func update_info() -> void:
	max_pp_label.text = str(pokemon.moves[assigned_move].max_pp)
	current_pp_label.text = str(pokemon.current_pp[assigned_move])
	pp_bar.value = roundi((float(pokemon.current_pp[assigned_move])/float(pokemon.moves[assigned_move].max_pp)) * 48)
	if pokemon.current_pp[assigned_move] == 0:
		disabled = true
	else:
		disabled = false

func _pressed():
	emit_signal("pressed", assigned_move, self)
