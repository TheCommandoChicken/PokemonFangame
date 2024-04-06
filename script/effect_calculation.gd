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

signal move_used(move, user, target, crit, effective, miss) # This definitely needs to be refactored

func _ready() -> void: # This entire thing is almost verbatim duplicated from base_pokemon.gd, consider making it a function?
	var path = "res://resource/moves.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if not FileAccess.file_exists(path):
		return
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	move_table = test_json_conv.get_data()

func calculateMoveEffect(move_id: int, user: Pokemon, target: Pokemon):
	var move = Dictionary(move_table[str(move_id)])
	var user_type_1 = BasePokemon.pokemon_table[str(user.species)]["type_1"] # These should probably be Tuples
	var user_type_2 = BasePokemon.pokemon_table[str(user.species)]["type_2"]
	var target_type_1 = BasePokemon.pokemon_table[str(target.species)]["type_1"]
	var target_type_2 = BasePokemon.pokemon_table[str(target.species)]["type_2"]
	var miss : bool
	var power
	var accuracy
	
	hits = 1
	
	match int(move["category"]):
		0:
			attack = user.stats["attack"]
			defense = target.stats["defense"]
			power = move["base_power"]
			accuracy = move["accuracy"]
		1:
			attack = user.stats["sp_attack"]
			defense = target.stats["sp_defense"]
			power = move["base_power"]
			accuracy = move["accuracy"]
			
	match int(move["category"]):
		0,1:
			effective = Types.typeMatchup(move["type"], target_type_1, target_type_2)
			
			miss = checkAccuracy(move["accuracy"], user.stages["accuracy"], target.stages["evasiveness"])
			
			stab = calcStab(move["type"], user_type_1, user_type_2)
			
			effective_crit_stage = user.stages["crit"]
			
			if move.has("effects"):
				getEffects(move)
				checkEffectsPreDamage(move, user, target)
			
			for i in hits:
				crit = checkCrit(effective_crit_stage, user.affection)
				damage = calculateDamage(attack, defense, user.level, power, effective, stab, crit)
				
				if damage <= 0 && miss == false && effective != 0.0:
					damage = 1
				
				if miss:
					damage = 0
				
				print(damage)
		
	emit_signal("move_used", move_id, user.nickname, target.nickname, crit, effective, miss)

func checkAccuracy(accuracy: int, accuracy_stage: int, evasion_stage: int) -> bool:
	var stage = accuracy_stage - evasion_stage
	
	if stage >= 0 && stage <= 6:
		accuracy *= (abs(stage) + 3) / 3.0
	elif stage < 0 && stage >= -6:
		accuracy *= 3.0 / (abs(stage) + 3)
	elif stage > 6:
		accuracy *= 3
	elif stage < -6:
		accuracy *= 1.0/3.0
		
	print(accuracy)
	
	if randf_range(0, 1) * 100 > accuracy:
		return true
	
	return false

func calcStab(move_type: String, user_type_1: String, user_type_2: String) -> float:
	if move_type == user_type_1 || (move_type == user_type_2) && user_type_2 != "NONE":
		return 1.5
	else:
		return 1.0

func getEffects(move: Dictionary) -> void:
	effects = []
	for i in move["effects"].size():
			effects.append(move["effects"][i])

func checkEffectsPreDamage(move: Dictionary, user: Pokemon, target: Pokemon) -> void: # Why do we have two separate functions for checking effects
	for i in effects:
		match i["effect"]:
			"multi-hit":
				strike_chances = i["strike_chances"]
				
				hits = hitCount()
				
			"increased_crit":
				effective_crit_stage += 1
			
			"change_stat":
				if (randf_range(0, 1) * 100) <= i["chance"]:
					var factors = i["factors"]
					
					match i["target"]:
						"self":
							for j in factors.size():
								user.stages[j] += factors[j]
						"target":
							for j in factors.size():
								target.stages[j] += factors[j]
			
			"inflict_status":
				if (randf_range(0, 1) * 100) <= i["chance"]:
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

func checkEffectsPostDamage(move: Dictionary, user: Pokemon, target: Pokemon) -> void:
	if effects.has("recoil"):
		var amount = move["effects"][effects.find("recoil")]["amount"]
			
		if move["effects"][effects.find("recoil")]["from_user"]:
			recoil = calculateRecoil(amount, user.stats["max_health"])
		else:
			recoil = calculateRecoil(amount, damage)
		
		print("recoiled for ", recoil, " damage")

func checkCrit(stage: int, affection: int) -> float:
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

func calculateDamage(attack : int, defense : int, level : int, power : int, effectiveness : float, stab : float, crit : float) -> int: # What the fuck
	return int(((((((((2 * level) / 5) + 2) * power * max((attack / defense), 1)) / 50) + 2) * randf_range(0.85, 1.0) * stab) * crit) * effectiveness)

func hitCount() -> int:
	var rand = randf_range(0.01, 1) * 100
	
	for i in strike_chances.size() - 1:
		if rand > strike_chances[i] && rand <= strike_chances[i + 1]:
			return i + 1
	
	return 0

func calculateRecoil(amount : float, source : int) -> int:
	return int(source * amount)
