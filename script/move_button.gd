extends BaseButton

@export var pp_bar : TextureProgressBar
@export var max_pp_label : Label
@export var current_pp_label : Label
@export var move_name_label : Label
@export var type_icon : TextureRect
@export var background : TextureRect

func update_info(move : Move, current_pp : int):
	move_name_label.text = TextManager.get_move_name(str(move.id), Settings.current_language)
	max_pp_label.text = str(EffectCalculation.move_table[str(move.id)]["pp"])
	current_pp_label.text = str(current_pp)
	current_pp = roundi((current_pp/EffectCalculation.move_table[str(move.id)]["pp"]) * 48)
	pp_bar.value = current_pp
	if current_pp == 0:
		disabled = true
	else:
		disabled = false
