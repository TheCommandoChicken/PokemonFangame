extends Node

signal queue_text(key, init_pokemon, init_move, init_target)

var pokemon_1 = Pokemon.new({"nickname": "Voltorb", "species": 100,"ivs":{"health": randf_range(0.00, 0.31) * 100,"attack": randf_range(0.00, 0.31) * 100,"defense": randf_range(0.00, 0.31) * 100,"sp_attack": randf_range(0.00, 0.31) * 100,"sp_defense": randf_range(0.00, 0.31) * 100,"speed": randf_range(0.00, 0.31) * 100}, "level": 100})
var pokemon_2 = Pokemon.new({"nickname": "Voltorb", "species": 100,"ivs":{"health": randf_range(0.00, 0.31) * 100,"attack": randf_range(0.00, 0.31) * 100,"defense": randf_range(0.00, 0.31) * 100,"sp_attack": randf_range(0.00, 0.31) * 100,"sp_defense": randf_range(0.00, 0.31) * 100,"speed": randf_range(0.00, 0.31) * 100}, "level": 100})
@export var moves: Array # No idea what this is doing

func _ready() -> void:
	EffectCalculation.connect("move_used", Callable(self, "_on_move_used"))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		Settings.updateMove()
		EffectCalculation.calculateMoveEffect(Settings.move, pokemon_1, pokemon_2)
	if Input.is_action_just_pressed("ui_left"):
		pokemon_1.updateStats()
		pokemon_2.updateStats()

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
