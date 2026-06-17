extends Control

var game = null
var client_spawner = null

@onready var infinite_money_button: CheckButton = %InfiniteMoney
@onready var status_label: Label = %Status


func _ready() -> void:
	%CloseButton.pressed.connect(close_menu)
	infinite_money_button.toggled.connect(_on_infinite_money_toggled)
	%AddMoney.pressed.connect(_on_add_money_pressed)
	%UnlockFeatures.pressed.connect(_on_unlock_features_pressed)
	%Restock.pressed.connect(_on_restock_pressed)
	%SpawnSum.pressed.connect(_spawn_client.bind("soma"))
	%SpawnCart.pressed.connect(_spawn_client.bind("compra_variavel"))
	%SpawnGolden.pressed.connect(_spawn_client.bind("cliente_ouro"))
	%SpawnChange.pressed.connect(_spawn_client.bind("troco"))
	%SpawnStock.pressed.connect(_spawn_client.bind("estoque"))
	hide()


func setup(game_node, spawner_node) -> void:
	game = game_node
	client_spawner = spawner_node


func open_menu() -> void:
	infinite_money_button.button_pressed = game != null and game.debug_infinite_money
	status_label.text = "Ferramentas de teste ativas."
	show()
	move_to_front()


func close_menu() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func _on_infinite_money_toggled(enabled: bool) -> void:
	if game == null:
		return
	game.set_debug_infinite_money(enabled)
	status_label.text = "Dinheiro infinito: %s" % ("LIGADO" if enabled else "DESLIGADO")


func _on_add_money_pressed() -> void:
	EventBus.emit_signal("update_money", 1000)
	status_label.text = "+1000 adicionados."


func _on_unlock_features_pressed() -> void:
	for feature_id in FeatureManager.get_all_features():
		FeatureManager.unlock_feature(feature_id)
	Saves.solicitar_save("debug_features")
	status_label.text = "Todas as features foram liberadas."


func _on_restock_pressed() -> void:
	for item in StockSystem.get_stock():
		StockSystem.add_item(item.name, 10)
	Saves.solicitar_save("debug_estoque")
	EventBus.emit_signal("get_estoque")
	status_label.text = "+10 unidades de cada produto."


func _spawn_client(type: String) -> void:
	if client_spawner == null:
		status_label.text = "Spawner de clientes indisponivel."
		return
	if client_spawner.spawnar_cliente_debug(type):
		status_label.text = "Cliente %s criado." % type
		close_menu()
	else:
		status_label.text = "Finalize o cliente atual ou reponha o estoque."
