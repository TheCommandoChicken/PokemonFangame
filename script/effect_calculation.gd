extends Node
class_name Fucker # No idea why I called it that

var move_table
var effective_crit_stage: int
var strike_chances : Array
var hits = 1
var effects : Array
var damage : int
var stab : float
var effective : float
var crit : float
var attack = 1
var defense = 1
var recoil : int
var attack_id : String
var defense_id : String

signal move_used(move, user, target, crit, effective, miss)

func _ready() -> void: # This entire thing is almost verbatim duplicated from base_pokemon.gd, consider making it a function?
	var path = "res://resource/moves.json"
	move_table = DataManager.generic_json_read(path)

func calculate_move_effect(move_id: int, user: Pokemon, target: Pokemon):
	var move = user.moves[move_id]
	var miss : bool
	var power
	
	hits = 1
	
	match move.category:
		move.Category.PHYSICAL:
			attack = user.stats["attack"]
			defense = target.stats["defense"]
			attack_id = "attack"
			defense_id = "defense"
		move.Category.SPECIAL:
			attack = user.stats["sp_attack"]
			defense = target.stats["sp_defense"]
			attack_id = "sp_attack"
			defense_id = "sp_defense"
			
			
	match move.category:
		move.Category.PHYSICAL, move.Category.SPECIAL:
			power = move.power
			
			effective = Types.type_matchup(move.type, target.get_types())
			
			miss = check_accuracy(move.accuracy, user.stages.acc, target.stages.eva)
			
			stab = calc_stab(move.type, user.get_types())
			
			effective_crit_stage = user.stages.crt
			
			for i in hits:
				crit = check_crit(effective_crit_stage, user.affection)
				damage = max(calculate_damage(attack * get_stage_multiplier(user.stages[attack_id]), defense * get_stage_multiplier(target.stages[defense_id]), user.level, power, effective, stab, crit), 1)
				
				if miss || effective == 0.0:
					damage = 0
				
				print("Dealt ", damage)
				
				target.stats.current_health -= damage
				
				print("Miss: ", miss)
		
	user.moves[move_id].pp -= 1

	await emit_signal("move_used", move_id, user.nickname, target.nickname, crit, effective, miss)

func check_accuracy(accuracy: float, accuracy_stage: int, evasion_stage: int) -> bool:
	var mstage = accuracy_stage - evasion_stage
	
	if mstage >= 0:
		accuracy *= min(abs(mstage) + 3, 9) / 3.0
	else:
		accuracy *= 3.0 / min(abs(mstage) + 3, 9)
		
	#accuracy *= pow(min(abs(mstage) + 3, 9) / 3, signf(mstage)) # For some inexplicable reason this doesn't work
	
	print(accuracy)
	
	if randf_range(0, 1) > accuracy:
		return true
	
	return false

func calc_stab(move_type: String, user_types: Array) -> float:
	if move_type == user_types[0] || move_type == user_types[1]:
		return 1.5
	else:
		return 1.0

func get_effects(move: Dictionary) -> void:
	effects = []
	for i in move["effects"].size():
			effects.append(move["effects"][i])

func check_effects_pre_damage(move: Dictionary, user: Pokemon, target: Pokemon) -> void: # Why do we have two separate functions for checking effects
	for i in effects:
		match i["effect"]:
			"multi-hit":
				strike_chances = i["strike_chances"]
				
				hits = hit_count()
				
			"increased_crit":
				effective_crit_stage += 1
			
			"change_stat":
				if (randf_range(0, 1)) <= i["chance"]:
					var factors = i["factors"]
					
					match i["target"]:
						"self":
							for j in factors.size():
								user.stages[j] += factors[j]
						"target":
							for j in factors.size():
								target.stages[j] += factors[j]
			
			"inflict_status":
				if (randf_range(0, 1)) <= i["chance"]:
					var status = i["status"]
					
					match i["target"]:
						"self":
							if user.status == "NONE":
								user.status = status
								continue
							
							print("failed")
						"target":
							if target.status == "NONE":
								target.status = status
								continue
								
							print("failed")
				
				print(target.status)

func check_effects_post_damage(move: Dictionary, user: Pokemon, target: Pokemon) -> void:
	# if effects.has("recoil"):
		# var amount = move["effects"][effects.find("recoil")]["amount"]
			
		# if move["effects"][effects.find("recoil")]["from_user"]:
			# recoil = calculateRecoil(amount, user.stats["max_health"])
		# else:
			# recoil = calculateRecoil(amount, damage)
		
		# print("recoiled for ", recoil, " damage")
		pass

func check_crit(stage: int, affection: int) -> float:
	var chance : float
	
	match stage:
		0:
			chance = 1.0 / 24.0
		1:
			chance = 0.125
		2:
			chance = 0.5
		_:
			chance = 1
	
	if affection == 255:
		chance = chance * 2
	
	if randf_range(0, 1) <= chance:
		print("crit")
		return 1.5
	
	return 1.0

func calculate_damage(tattack : float, tdefense : float, tlevel : int, tpower : int, teffectiveness : float, tstab : float, tcrit : float) -> int: # What the fuck
	print(tattack)
	return int(((((((((2 * tlevel) / 5) + 2) * tpower * (tattack / tdefense)) / 50) + 2) * randf_range(0.85, 1.0) * tstab) * tcrit) * teffectiveness)

func hit_count() -> int:
	var rand = randf_range(0.01, 1) * 100
	
	for i in strike_chances.size() - 1:
		if rand > strike_chances[i] && rand <= strike_chances[i + 1]:
			return i + 1
	
	return 0

func calculate_recoil(amount : float, source : int) -> int:
	return int(source * amount)

func get_stage_multiplier(stage: int) -> float:
	if stage >= 0:
		return min(stage + 2, 8) / 2.0
	else:
		return 2.0 / min(abs(stage) + 2, 8)
