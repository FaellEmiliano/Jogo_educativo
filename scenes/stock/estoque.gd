extends Control

var estoque = []
@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var botao_comprar = $Comprar

var item_template = preload("res://scenes/stock/item.tscn")
var carrinho = {}
var bonus_label: Label = null

func _on_button_pressed() -> void:
	queue_free()

func _ready() -> void:
	EventBus.send_estoque.connect(draw_estoque)
	_criar_bonus_label()
	EventBus.emit_signal("get_estoque")

func draw_estoque(est):
	estoque = est
	carrinho = _sanitize_cart()

	# limpa antes (IMPORTANTE)
	for child in grid_container.get_children():
		child.queue_free()

	for item in estoque:
		var item_instancia = item_template.instantiate()
		grid_container.add_child(item_instancia)

		item_instancia.setup(item)
		item_instancia.set_cart_count(int(carrinho.get(item.name, 0)))

		item_instancia.connect("adicionar", Callable(self, "_on_add"))
		item_instancia.connect("remover", Callable(self, "_on_remove"))
	_refresh_bonus_label()
	atualizar_ui()

func _on_add(nome):
	var current_amount = int(carrinho.get(nome, 0))
	if current_amount >= StockSystem.get_available_space(nome):
		return
	if not carrinho.has(nome):
		carrinho[nome] = 0
	
	carrinho[nome] += 1
	atualizar_ui()
	draw_estoque(StockSystem.get_stock())

func _on_remove(nome):
	if carrinho.has(nome):
		carrinho[nome] -= 1
		
		if carrinho[nome] <= 0:
			carrinho.erase(nome)

	atualizar_ui()
	draw_estoque(StockSystem.get_stock())

func get_preco(nome):
	for item in estoque:
		if item.name == nome:
			return item.price
	return 0

func atualizar_ui():
	var total_itens = 0
	var total_preco = 0
	carrinho = _sanitize_cart()

	for nome in carrinho:
		var qtd = carrinho[nome]
		var preco = get_preco(nome)

		total_itens += qtd
		total_preco += qtd * preco

	botao_comprar.text = "Comprar " + str(total_itens) + " itens\nTotal R$ " + str(total_preco)
	botao_comprar.disabled = total_itens == 0 or GameManager.money < total_preco

func _on_comprar_pressed() -> void:
	carrinho = _sanitize_cart()
	var total_preco = 0
	for nome in carrinho:
		total_preco += carrinho[nome] * get_preco(nome)

	if total_preco <= 0 or GameManager.money < total_preco:
		return

	for nome in carrinho:
		var qtd = carrinho[nome]
		StockSystem.add_item(nome, qtd)

	EventBus.emit_signal("update_money", -int(total_preco))
	carrinho.clear()
	atualizar_ui()
	draw_estoque(StockSystem.get_stock())
	EventBus.emit_signal("get_estoque")

func _sanitize_cart() -> Dictionary:
	var valid_cart := {}
	for nome in carrinho:
		var amount = min(int(carrinho[nome]), StockSystem.get_available_space(str(nome)))
		if amount > 0:
			valid_cart[nome] = amount
	return valid_cart

func _criar_bonus_label() -> void:
	bonus_label = Label.new()
	bonus_label.text = "Bônus ativo: prateleiras cheias! Recompensas dos clientes: 1.5x"
	bonus_label.visible = false
	bonus_label.position = Vector2(25, 8)
	bonus_label.size = Vector2(780, 28)
	add_child(bonus_label)

func _refresh_bonus_label() -> void:
	if bonus_label == null:
		return
	bonus_label.visible = StockSystem.is_stock_full()
