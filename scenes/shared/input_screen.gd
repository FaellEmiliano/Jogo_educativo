extends Control
@onready var input: LineEdit = $CenterContainer/Input



func send_input(text):
	EventBus.emit_signal("input_submitted",text)
	queue_free()

func _on_input_text_submitted(new_text: String) -> void:
	var array :Array = new_text.split(",")
	send_input([array])
