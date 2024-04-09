extends BaseButton

@export var pp_bar : TextureProgressBar
@export var max_pp_label : Label
@export var current_pp_label : Label
@export var move_name_label : Label
@export var type_icon : TextureRect
@export var background : TextureRect

func update_info(move : Dictionary):
	var current_pp = roundi((move.current_pp/EffectCalculation.move_table[str(move.id)]["pp"]) * 48)
	move_name_label.text = TextManager.get_move_name(move.id, Settings.current_language)
	max_pp_label.text = str(EffectCalculation.move_table[str(move.id)]["pp"])
	current_pp_label.text = str(move.current_pp)
	pp_bar.value = current_pp
	if move.current_pp == 0:
		disabled = true
	else:
		disabled = false