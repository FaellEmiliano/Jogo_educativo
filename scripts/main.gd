extends Node2D

var save_path = "user://userdata.save"

var money = 0
var steps_per_click = 1
var steps_to_complete = 5
var progress = 0

signal update_money
signal update_progress
signal reset_progress

func _on_clicker_pressed() -> void:
	progress += steps_per_click
	if progress >= steps_to_complete:
		money+= 1
		emit_signal("update_money",money)
		emit_signal("reset_progress")
		progress = 0
	else:
		emit_signal("update_progress",progress)
	save_data()
	
func save_data():
	var data = {
		"money": money
	}
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path,FileAccess.READ)
		var data = file.get_var()
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			money = data.get("money",0)
	else:
		save_data()

func _init() -> void:
	load_data()
