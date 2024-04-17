extends Node

func generic_json_read(path : String) -> Variant:
	if not FileAccess.file_exists(path):
		assert("File does not exist at the provided path.")
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	return json.get_data()
