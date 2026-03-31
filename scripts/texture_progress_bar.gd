extends TextureProgressBar


func _on_game_reset_progress() -> void:
	value = 0


func _on_game_update_progress(progress) -> void:
	value = progress
