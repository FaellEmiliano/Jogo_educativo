extends Node
@onready var hud: CanvasLayer = $"../HUD"

func _ready() -> void:
	EventBus.get_estoque.connect(send_estoque)

func send_estoque():
	EventBus.emit_signal("send_estoque", StockSystem.get_stock())
	if FeatureManager.has_feature(FeatureManager.FEATURE_STOCK) and StockSystem.has_any_items():
		var client_spawner = get_node_or_null("../Cliente_manager")
		if client_spawner != null and client_spawner.has_method("liberar_spawn"):
			client_spawner.liberar_spawn()

func _on_button_pressed() -> void:
	if not FeatureManager.has_feature(FeatureManager.FEATURE_STOCK):
		push_warning(FeatureManager.locked_message(FeatureManager.FEATURE_STOCK))
		return
	var estoque_scene = preload("res://scenes/stock/estoque.tscn").instantiate()
	hud.add_child(estoque_scene)
	
