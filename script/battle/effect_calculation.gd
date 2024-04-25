extends Node
class_name Fucker # No idea why I called it that

var move_table
var hits : int = 1
var damage : int
var stab : float
var recoil : int
var attack_id : String
var defense_id : String

signal move_used(move, user, target, crit, effective, miss)
signal gained_exp(user : Pokemon, amount : int, evs : Dictionary)

func _ready() -> void:
	var path = "res://resource/moves.json"
	move_table = DataManager.generic_json_read(path)

func calculate_move_effect(battle_participants: Array[BattleParticipant], move: Move, user: Pokemon, battle_type: Enums.BattleType) -> void:
	var miss : Array[bool]
	var effective : Array[float]
	var crit : Array[float]
	var power
	var active_pokemon : Array[Pokemon]
	for participant in battle_participants:
		active_pokemon.append_array(participant.active_pokemon)
	var targets : Array[Pokemon] = move.get_targets(active_pokemon, battle_type, active_pokemon.find(user))
	
	if not move.hit_friends: targets = remove_friendly_pokemon(targets, battle_participants, battle_type, user) 
	
	var effects : Array[MoveEffect] = get_effects(move)
	
	var effective_crit_stage : int = user.stages.crt
	
	for effect in effects:
		match effect.effect:
			Enums.MoveEffect.MULTIHIT:
				hits = hit_count(effect)
			Enums.MoveEffect.INCREASED_CRIT:
				effective_crit_stage += 1
	
	match move.category:
		Enums.Category.PHYSICAL:
			attack_id = "atk"
			defense_id = "def"
		Enums.Category.SPECIAL:
			attack_id = "spa"
			defense_id = "spd"
			
	match move.category:
		Enums.Category.PHYSICAL, Enums.Category.SPECIAL:
			power = move.power
			
			stab = calc_stab(move.type, user.base.types)
			
			for target in targets:
				var target_id = targets.find(target)
				effective.append(Types.type_matchup(move.type, target.base.types))
				miss.append(check_accuracy(move.accuracy, user.stages.acc, target.stages.eva))
				for i in hits:
					crit.append(check_crit(effective_crit_stage, user.affection))
					damage = max(calculate_damage(user.stats[attack_id] * get_stage_multiplier(user.stages[attack_id]), target.stats[defense_id] * get_stage_multiplier(target.stages[defense_id]), user.level, power, effective[target_id], stab, crit[target_id]), 1)
					
					if miss[target_id] or effective[target_id] == 0.0:
						damage = 0
			
					print("Dealt ", damage)
				
					target.stats.current_hp -= damage
					
					if target.stats.current_hp <= 0:
						emit_signal("gained_exp", user, calculate_exp(), target.base.ev_yield)
					
				
				print("Miss: ", miss)
			
				await emit_signal("move_used", move.id, user.nickname, target.nickname, crit, effective, miss)

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

func calc_stab(move_type: Types.Type, user_types: Array[Types.Type]) -> float:
	if move_type == user_types[0] or move_type == user_types[1]:
		return 1.5
	else:
		return 1.0

func get_effects(move: Move) -> Array[MoveEffect]:
	return move.effects

#func check_effects_pre_damage(move: Dictionary, user: Pokemon, target: Pokemon) -> void: # Why do we have two separate functions for checking effects
	#for i in effects:
		#match i["effect"]:
			#"inflict_status":
				#if (randf_range(0, 1)) <= i["chance"]:
					#var status = i["status"]
					#
					#match i["target"]:
						#"self":
							#if user.status == "NONE":
								#user.status = status
								#continue
							#
							#print("failed")
						#"target":
							#if target.status == "NONE":
								#target.status = status
								#continue
								#
							#print("failed")
				#
				#print(target.status)

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
	return int(((((((((2 * tlevel) / 5) + 2) * tpower * (tattack / tdefense)) / 50) + 2) * randf_range(0.85, 1.0) * tstab) * tcrit) * teffectiveness)

func hit_count(effect : MoveEffect) -> int:
	var rand = randf_range(0.01, 1) * 100
	
	for i in effect.strike_chances.size() - 1:
		if rand > effect.strike_chances[i] && rand <= effect.strike_chances[i + 1]:
			return i + 1
	
	return 0

func calculate_recoil(amount : float, source : int) -> int:
	return int(source * amount)

func get_stage_multiplier(stage: int) -> float:
	if stage >= 0:
		return min(stage + 2, 8) / 2.0
	else:
		return 2.0 / min(abs(stage) + 2, 8)

func calculate_exp() -> int:
	return 1

func find_user_parent(battle_participants: Array[BattleParticipant], user: Pokemon) -> int:
	for participant in battle_participants:
		if user in participant.active_pokemon:
			return battle_participants.find(participant)
	return -1

func remove_friendly_pokemon(targets : Array[Pokemon], battle_participants : Array[BattleParticipant], battle_type : Enums.BattleType, user : Pokemon) -> Array[Pokemon]: # All of this code exists only to remove friendly pokemon from the targets list
	var user_parent = find_user_parent(battle_participants, user)
	for pokemon in battle_participants[user_parent].active_pokemon:
		targets.erase(pokemon)
	
	if battle_type == Enums.BattleType.MULTI:
		match user_parent:
			0:
				for pokemon in battle_participants[1].active_pokemon:
					targets.erase(pokemon)
			1:
				for pokemon in battle_participants[0].active_pokemon:
					targets.erase(pokemon)
			2:
				for pokemon in battle_participants[3].active_pokemon:
					targets.erase(pokemon)
			3:
				for pokemon in battle_participants[2].active_pokemon:
					targets.erase(pokemon)
	return targets

func get_stat_change(move : Move, effect : MoveEffect, target : Pokemon):
	if (randf_range(0, 1)) <= effect.chance:
		var factors = effect.factors
		
		for i in factors.size() - 1:
			target.stages[i] += factors[i]
