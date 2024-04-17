extends Node
class_name BattleManager

signal queue_text(key, init_pokemon, init_move, init_target)
signal disable_buttons()
signal enable_buttons()

@export var pokemon : Array
var moves : Array
var action_list : Array
@export var health_bar : ProgressBar
@export var move_buttons : Control

func _ready() -> void:
	var move1 = "res://resource/moves/aerial_ace.tres"
	pokemon = [Pokemon.new(load("res://resource/pokemon/bulbasaur.tres"),{"hp": 0,"atk": 0,"def": 0,"spa": 0,"spd": 0,"spe": 0}, 100, [load("res://resource/moves/pound.tres"), load(move1), load(move1), load(move1)]), Pokemon.new(load("res://resource/pokemon/bulbasaur.tres"),{"hp": 0,"atk": 0,"def": 0,"spa": 0,"spd": 0,"spe": 0}, 100, [load(move1), load(move1), load(move1), load(move1)])]
	EffectCalculation.connect("move_used", Callable(self, "_on_move_used"))
	for button in move_buttons.get_children():
		button.pressed.connect(_on_move_button_pressed.bind())
		button.assign_move(pokemon[0], button.get_index())
	health_bar.max_value = pokemon[1].stats.max_hp
	health_bar.value = pokemon[1].stats.current_hp

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		execute_turn()
	if Input.is_action_just_pressed("ui_left"):
		pokemon[0].update_stats()
		pokemon[1].update_stats()

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
		health_bar.value = pokemon[1].stats.current_hp
		
	action_list.clear()
	moves.clear()
