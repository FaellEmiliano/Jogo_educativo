extends MarginContainer

var dragging = false
var drag_offset = Vector2.ZERO

func _gui_input(event):

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_window().start_drag()
