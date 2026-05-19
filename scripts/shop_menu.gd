extends HBoxContainer
@onready var game: Control = $".."
@onready var troco: Button = $"ColorRect3/VBoxContainer/Troco/Troco/MarginContainer/updt 1/troco"



func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	update(0)
	Eventos.update_money.connect(update)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		position += Vector2(323,0)
	else:
		position -= Vector2(323,0)


func _on_troco_pressed() -> void:
	Eventos.emit_signal("update_state",2)
	game.upgrades.append("troco")
	Eventos.emit_signal("update_money",-20)
	troco.text = "Comprado"
	troco.disabled = true
	
func update(_num):
	if troco.text != "Comprado" and game.money >= 20:
		troco.disabled = false
	if "troco" in game.upgrades:
		troco.text = "Comprado"
		troco.disabled = true
