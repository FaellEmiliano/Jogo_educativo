extends Label


func _on_game_update_progress(progress) -> void:
	text = str(progress) + "/5"


func _on_game_reset_progress() -> void:
	text = "0/5"
