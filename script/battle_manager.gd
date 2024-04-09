extends Node

signal queue_text(key, init_pokemon, init_move, init_target)

var pokemon_1 = Pokemon.new({"nickname": "Voltorb", "species": 100,"ivs":{"health": randi_range(0, 31),"attack": randi_range(0, 31),"defense": randi_range(0, 31),"sp_attack": randi_range(0, 31),"sp_defense": randi_range(0, 31),"speed": randi_range(0, 31)}, "level": 100, "moves": [["1", 0], ["24", 0], ["17", 0], ["99", 0]]})
var pokemon_2 = Pokemon.new({"nickname": "Voltorb2", "species": 100,"ivs":{"health": randi_range(0, 31),"attack": randi_range(0, 31),"defense": randi_range(0, 31),"sp_attack": randi_range(0, 31),"sp_defense": randi_range(0, 31),"speed": randi_range(0, 31)}, "level": 100, "moves": [["1", 0], ["24", 0], ["17", 0], ["99", 0]]})
@export var moves : Array
@export var health_bar : ProgressBar
@export var move_buttons : Control
func _ready() -> void:
	EffectCalculation.connect("move_used", Callable(self, "_on_move_used"))
	for i in move_buttons.get_children():
		i.pressed.connect(_on_move_button_pressed.bind(i))
		i.get_node("Label").text = TextManager.get_move_name(pokemon_1.moves[i.get_index()][0], Settings.current_language)
	health_bar.max_value = pokemon_2.stats.max_health
	health_bar.value = pokemon_2.stats.current_health

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		EffectCalculation.calculate_move_effect(Settings.move, pokemon_1, pokemon_2)
		health_bar.value = pokemon_2.stats.current_health
	if Input.is_action_just_pressed("ui_left"):
		pokemon_1.update_stats()
		pokemon_2.update_stats()

func _on_move_button_pressed(button : TextureButton):
	EffectCalculation.calculate_move_effect(int(pokemon_1.moves[button.get_index()][0]), pokemon_1, pokemon_2)
	health_bar.value = pokemon_2.stats.current_health

func _on_queue_move(move, speed, priority, user, target): # As far as I can tell this function is never called
	for i in moves.size() - 1:
		if moves[i][2] < priority || (moves[i][2] == priority && moves[i][1] <= speed):
			moves.insert(i, [move, speed, priority, user, target])
			return
		else:
			continue
	
	moves.append([move, speed, priority, user, target])

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
