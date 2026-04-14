extends Control



func _on_fechar_pressed() -> void:
	Eventos.emit_signal("redraw_buttons")
	queue_free()
	
