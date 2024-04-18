extends Node
class_name BattleManager

signal queue_text(key, init_pokemon, init_move, init_target)
signal disable_buttons()
signal enable_buttons()

@export var pokemon : Array = [null, null]
var moves : Array
var action_list : Array
@export var ui : Control
@export var encounter_areas : Node3D

func _ready() -> void:
	EffectCalculation.connect("move_used", Callable(self, "_on_move_used"))
	for area in encounter_areas.get_children():
		area.connect("triggered_encounter", Callable(self, "_on_encounter_triggered"))
	for button in ui.get_buttons():
		button.pressed.connect(_on_move_button_pressed.bind())

func _process(delta: float) -> void:
	pass

func _on_encounter_triggered(species : BasePokemon, level : int, player : CharacterBody3D):
	pokemon[0] = player.pokemon[0]
	
	init_wild_pokemon(species, level)
	
	for button in ui.get_buttons():
		button.assign_move(pokemon[0], button.get_index())
	
func _on_move_button_pressed(assigned_move : int, button : TextureButton):
	action_list.append({"action_type": "use_move", "user": pokemon[0], "target": pokemon[1], "move": assigned_move})
	pokemon[0].current_pp[assigned_move] -= 1
	button.update_info()
	emit_signal("disable_buttons")
	execute_turn()

func ai_choose_move(user : Pokemon, opposing_pokemon : Pokemon):
	action_list.append({"action_type": "use_move", "user": user, "target": opposing_pokemon, "move": randi_range(0, 3)})
	print(action_list)

func queue_move(move, speed, priority, user, target):
	for i in moves.size():
		if moves[i][2] < priority || (moves[i][2] == priority && moves[i][1] <= speed):
			moves.insert(i, [move, speed, priority, user, target])
			print(moves)
			return
		else:
			continue
	
	moves.append([move, speed, priority, user, target])
	print(moves)

func _on_move_used(move, user, target, crit, effective, miss):
	emit_signal("queue_text", "battle.move_used", user, move, target)
	
	if miss:
		emit_signal("queue_text", "battle.miss", user, move, target)
		return
	
	if crit == 1.5:
		emit_signal("queue_text", "battle.critical_hit", user, move, target)
	
	match effective:
		0.0:
			emit_signal("queue_text", "battle.immune", user, move, target)
		0.25, 0.5:
			emit_signal("queue_text", "battle.ineffective", user, move, target)
		2.0, 4.0:
			emit_signal("queue_text", "battle.super_effective", user, move, target)

func _on_text_finished():
	emit_signal("enable_buttons")

func execute_turn():
	ai_choose_move(pokemon[1], pokemon[0])
	for i in action_list.size():
		var action = action_list[i]
		match action.action_type:
			"use_move":
				queue_move(action.move, action.user.stats.spe, action.user.moves[action.move].priority, action.user, action.target)
			
	
	for move in moves:
		await EffectCalculation.calculate_move_effect(int(move[0]), move[3], move[4])
		ui.health_bar.value = pokemon[1].stats.current_hp
		
	action_list.clear()
	moves.clear()

func init_wild_pokemon(wild_pokemon : BasePokemon, level : int):
	pokemon[1] = Pokemon.new(wild_pokemon, {"hp": randi_range(0, 31),"atk": randi_range(0, 31),"def": randi_range(0, 31),"spa": randi_range(0, 31),"spd": randi_range(0, 31),"spe": randi_range(0, 31)}, level)
	pokemon[1].moves = pokemon[1].get_moveset_at_level(level)
	pokemon[1].stats.current_hp = pokemon[1].stats.max_hp
	ui.health_bar.max_value = pokemon[1].stats.max_hp
	ui.health_bar.value = pokemon[1].stats.current_hp
