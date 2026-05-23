extends VBoxContainer
@onready var rich_text_label: RichTextLabel = $ColorRect3/MarginContainer/VBoxContainer/DebugFrame/RichTextLabel



func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		position -= Vector2(0,404)
	else:
		position += Vector2(0,404)

func _ready() -> void:
	EventBus.send_debug.connect(updt_debug)
	
func updt_debug(texto):
	rich_text_label.text = str(texto)
