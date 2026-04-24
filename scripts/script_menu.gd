extends VBoxContainer


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		position -= Vector2(0,333)
	else:
		position += Vector2(0,333)
