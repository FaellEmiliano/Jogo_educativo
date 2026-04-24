extends Control



func _on_fechar_pressed() -> void:
	Eventos.emit_signal("redraw_buttons")
	queue_free()
	


func _on_cliente_pressed() -> void:
	Eventos.emit_signal("open_client_terminal")
