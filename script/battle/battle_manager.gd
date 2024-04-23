extends Node
class_name BattleManager

signal queue_text(key, init_pokemon, init_move, init_target)
signal disable_buttons()
signal enable_buttons()

@export var battle_participants : Array[BattleParticipant]
@export var battle_type : Enums.BattleType
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

func _on_encounter_triggered(species : BasePokemon, level : int, player : CharacterBody3D) -> void:
	battle_participants.append(BattleParticipant.new(player.pokemon))
	
	init_wild_pokemon(species, level)
	
	for button in ui.get_buttons():
		button.assign_move(battle_participants[0].selected_pokemon, battle_participants[0].selected_pokemon.moves[button.get_index()])
	
func _on_move_button_pressed(assigned_move : int, button : TextureButton) -> void:
	var user = battle_participants[0].selected_pokemon
	match battle_type:
		Enums.BattleType.STANDARD, Enums.BattleType.ROTATION, Enums.BattleType.RAID:
			action_list.append({"action_type": "use_move", "user": user, "target": battle_participants[1], "move": assigned_move})
			emit_signal("player_turn_end")
		Enums.BattleType.DOUBLE, Enums.BattleType.TRIPLE, Enums.BattleType.HORDE:
			emit_signal("player_choose_target")
	user.current_pp[str(assigned_move)] -= 1
	button.update_info()
	emit_signal("disable_buttons")
	execute_turn()

func ai_choose_move(user : Pokemon, opposing_pokemon : Array[Pokemon]) -> void:
	action_list.append({"action_type": "use_move", "user": user, "target": opposing_pokemon.pick_random(), "move": user.moves.pick_random()})
	print(action_list)

func queue_move(move, speed, priority, user, target) -> void:
	for i in moves.size():
		if moves[i][2] < priority or (moves[i][2] == priority and moves[i][1] <= speed):
			moves.insert(i, [move, speed, priority, user, target])
			print(moves)
			return
		else:
			continue
	
	moves.append([move, speed, priority, user, target])
	print(moves)

func _on_move_used(move, user, target, crit, effective, miss) -> void:
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

func _on_text_finished() -> void:
	emit_signal("enable_buttons")

func execute_turn() -> void:
	ai_choose_move(battle_participants[1].selected_pokemon, battle_participants[0].active_pokemon)
	for i in action_list.size():
		var action = action_list[i]
		match action.action_type:
			"use_move":
				var move = load(DataManager.load_move(action.move))
				queue_move(move, action.user.stats.spe, move.priority, action.user, action.target)
			
	
	for move in moves:
		await EffectCalculation.calculate_move_effect(move[0], move[3], move[4])
		ui.health_bar.value = battle_participants[1].active_pokemon[0].stats.current_hp
		
	action_list.clear()
	moves.clear()

func init_wild_pokemon(wild_pokemon : BasePokemon, level : int) -> void:
	battle_participants.append(BattleParticipant.new([Pokemon.new(wild_pokemon, {"hp": randi_range(0, 31),"atk": randi_range(0, 31),"def": randi_range(0, 31),"spa": randi_range(0, 31),"spd": randi_range(0, 31),"spe": randi_range(0, 31)}, level)]))
	var enemy = battle_participants[1]
	enemy.selected_pokemon.stats.current_hp = enemy.selected_pokemon.stats.max_hp
	ui.health_bar.max_value = enemy.selected_pokemon.stats.max_hp
	ui.health_bar.value = enemy.selected_pokemon.stats.current_hp
