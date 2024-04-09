extends Node

signal queue_text(key, init_pokemon, init_move, init_target)

var pokemon_1 = Pokemon.new({"nickname": "Voltorb", "species": 100,"ivs":{"health": randi_range(0, 31),"attack": randi_range(0, 31),"defense": randi_range(0, 31),"sp_attack": randi_range(0, 31),"sp_defense": randi_range(0, 31),"speed": randi_range(0, 31)}, "level": 100, "moves": [{"id": "1", "current_pp": 35}, {"id": "24", "current_pp": 30}, {"id": "17", "current_pp": 35}, {"id": "99", "current_pp": 20}]})
var pokemon_2 = Pokemon.new({"nickname": "Voltorb2", "species": 100,"ivs":{"health": randi_range(0, 31),"attack": randi_range(0, 31),"defense": randi_range(0, 31),"sp_attack": randi_range(0, 31),"sp_defense": randi_range(0, 31),"speed": randi_range(0, 31)}, "level": 100, "moves": [{"id": "1", "current_pp": 35}, {"id": "24", "current_pp": 30}, {"id": "17", "current_pp": 35}, {"id": "99", "current_pp": 20}]})
@export var moves : Array
@export var action_list : Array
@export var health_bar : ProgressBar
@export var move_buttons : Control

func _ready() -> void:
	EffectCalculation.connect("move_used", Callable(self, "_on_move_used"))
	for button in move_buttons.get_children():
		button.pressed.connect(_on_move_button_pressed.bind(button))
		button.update_info(pokemon_1.moves[button.get_index()])
	health_bar.max_value = pokemon_2.stats.max_health
	health_bar.value = pokemon_2.stats.current_health

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		execute_turn()
	if Input.is_action_just_pressed("ui_left"):
		pokemon_1.update_stats()
		pokemon_2.update_stats()

func _on_move_button_pressed(button : TextureButton):
	action_list.append({"action_type": "use_move", "user": pokemon_1, "target": pokemon_2, "move_id": pokemon_1.moves[button.get_index()].id})
	button.update_info(pokemon_1.moves[button.get_index()])

func ai_choose_move(pokemon : Pokemon, opposing_pokemon : Pokemon):
	action_list.append({"action_type": "use_move", "user": pokemon, "target": opposing_pokemon, "move_id": pokemon.moves[randi_range(0, 3)].id})
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

func execute_turn():
	ai_choose_move(pokemon_2, pokemon_1)
	for i in action_list.size():
		var action = action_list[i]
		match action.action_type:
			"use_move":
				queue_move(action.move_id, action.user.stats.speed, EffectCalculation.move_table[str(action.move_id)].priority, action.user, action.target)
			
	
	for move in moves:
		await EffectCalculation.calculate_move_effect(int(move[0]), move[3], move[4])
		health_bar.value = pokemon_2.stats.current_health
		
	action_list.clear()
	moves.clear()
