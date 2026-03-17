extends CharacterBody2D
class_name Robo

func mover(dir:Vector2):
	position += dir *32


func _init() -> void:
	mover(Vector2.DOWN)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		Eventos.emit_signal('conectar_terminal',self)
