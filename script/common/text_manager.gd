extends Node

func get_message(key : String, lang : String) -> String:
	var path = "res://resource/local_" + lang + ".json"
	return String(DataManager.generic_json_read(path)[str(key)])

func get_move_name(move_id : String, lang : String) -> String:
	var path = "res://resource/moves_" + lang + ".json"
	return String(DataManager.generic_json_read(path)[str(move_id)])
