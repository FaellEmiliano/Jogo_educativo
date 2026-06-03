extends Control

var estoque = []
@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var botao_comprar = $Comprar

var item_template = preload("res://scenes/stock/item.tscn")
var carrinho = {}

func _on_button_pressed() -> void:
	queue_free()

func _ready() -> void:
	EventBus.send_estoque.connect(draw_estoque)
	EventBus.emit_signal("get_estoque")

func draw_estoque(est):
	estoque = est

	# limpa antes (IMPORTANTE)
	for child in grid_container.get_children():
		child.queue_free()

	for item in estoque:
		var item_instancia = item_template.instantiate()
		grid_container.add_child(item_instancia)

		item_instancia.setup(item)

		item_instancia.connect("adicionar", Callable(self, "_on_add"))
		item_instancia.connect("remover", Callable(self, "_on_remove"))

func _on_add(nome):
	if not carrinho.has(nome):
		carrinho[nome] = 0
	
	carrinho[nome] += 1
	atualizar_ui()

func _on_remove(nome):
	if carrinho.has(nome):
		carrinho[nome] -= 1
		
		if carrinho[nome] <= 0:
			carrinho.erase(nome)

	atualizar_ui()

func get_preco(nome):
	for item in estoque:
		if item.name == nome:
			return item.price
	return 0

func atualizar_ui():
	var total_itens = 0
	var total_preco = 0

	for nome in carrinho:
		var qtd = carrinho[nome]
		var preco = get_preco(nome)

		total_itens += qtd
		total_preco += qtd * preco

	botao_comprar.text = "Comprar " + str(total_itens) + " itens\nTotal R$ " + str(total_preco)
	botao_comprar.disabled = total_itens == 0 or GameManager.money < total_preco

func _on_comprar_pressed() -> void:
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
