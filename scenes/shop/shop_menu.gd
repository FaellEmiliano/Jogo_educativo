extends HBoxContainer

@onready var troco: Button = $"ColorRect3/VBoxContainer/Troco/Troco/MarginContainer/updt 1/troco"


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	_atualizar_ui(0)
	EventBus.update_money.connect(_atualizar_ui)


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		position += Vector2(323, 0)
	else:
		position -= Vector2(323, 0)


func _on_troco_pressed() -> void:
	GameManager.unlocked_mechanics["change"] = true
	GameManager.upgrades.append("troco")
	EventBus.emit_signal("update_money", -20)
	troco.text = "Comprado"
	troco.disabled = true


func _atualizar_ui(_num) -> void:
	if troco.text != "Comprado" and GameManager.money >= 20:
		troco.disabled = false
	if "troco" in GameManager.upgrades:
		troco.text = "Comprado"
		troco.disabled = true
