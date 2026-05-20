extends Node
@onready var hud: CanvasLayer = $"../HUD"

func _ready() -> void:
	EventBus.get_estoque.connect(send_estoque)

func send_estoque():
	EventBus.emit_signal("send_estoque", StockSystem.get_stock())

func _on_button_pressed() -> void:
	var estoque_scene = preload("res://scenes/stock/estoque.tscn").instantiate()
	hud.add_child(estoque_scene)
	
