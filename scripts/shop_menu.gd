extends HBoxContainer
@onready var troco: Button = $"ColorRect3/VBoxContainer/NinePatchRect/MarginContainer/updt 1/troco"
@onready var game: Control = $".."


func _ready() -> void:
	Eventos.update_money.connect(update)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		position += Vector2(323,0)
	else:
		position -= Vector2(323,0)


func _on_troco_pressed() -> void:
	Eventos.emit_signal("update_state",2)
	troco.text = "Comprado"
	troco.disabled = true
	
func update(_num):
	if troco.text != "Comprado" and game.money >= 20:
		troco.disabled = false
