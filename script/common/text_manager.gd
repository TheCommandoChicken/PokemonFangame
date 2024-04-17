extends Node

func get_message(key : String, lang : String) -> String:
	var path = "res://resource/json/local_" + lang + ".json"
	return String(DataManager.generic_json_read(path)[str(key)])

func get_move_name(move_id : String, lang : String) -> String:
	return tr(String("MOVE" + move_id))
