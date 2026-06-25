extends Control

var estoque = []
@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var botao_comprar = $Comprar
@onready var purchase_summary_label: Label = $PurchaseSummaryPanel/MarginContainer/PurchaseSummaryLabel

var item_template = preload("res://scenes/stock/item.tscn")
var selected_quantities = {}
var item_cards = {}
var bonus_label: Label = null
var aviso_label: Label = null

func _on_button_pressed() -> void:
	queue_free()

func _ready() -> void:
	EventBus.send_estoque.connect(draw_estoque)
	_criar_bonus_label()
	_criar_aviso_label()
	EventBus.emit_signal("get_estoque")

func draw_estoque(est):
	estoque = est
	selected_quantities = _sanitize_selected_quantities()
	item_cards.clear()

	# limpa antes (IMPORTANTE)
	for child in grid_container.get_children():
		child.queue_free()

	for item in estoque:
		var item_instancia = item_template.instantiate()
		grid_container.add_child(item_instancia)

		item_instancia.setup(item, get_selected_quantity(item.name))
		item_cards[item.name] = item_instancia

		item_instancia.connect("adicionar", Callable(self, "_on_add"))
		item_instancia.connect("remover", Callable(self, "_on_remove"))
	_refresh_bonus_label()
	refresh_stock_ui()

func _on_add(nome):
	increase_selected_quantity(str(nome))

func _on_remove(nome):
	decrease_selected_quantity(str(nome))

func increase_selected_quantity(item_id: String) -> void:
	var current_amount = get_selected_quantity(item_id)
	var remaining_capacity = get_remaining_capacity(item_id)
	if current_amount >= remaining_capacity:
		_show_message("Limite de estoque atingido para " + item_id + ".")
		return

	selected_quantities[item_id] = current_amount + 1
	_clear_message()
	refresh_stock_ui()

func decrease_selected_quantity(item_id: String) -> void:
	var current_amount = get_selected_quantity(item_id)
	if current_amount <= 0:
		return

	var new_amount = current_amount - 1
	if new_amount <= 0:
		selected_quantities.erase(item_id)
	else:
		selected_quantities[item_id] = new_amount
	_clear_message()
	refresh_stock_ui()

func get_selected_quantity(item_id: String) -> int:
	return max(0, int(selected_quantities.get(item_id, 0)))

func get_remaining_capacity(item_id: String) -> int:
	return StockSystem.get_available_space(item_id)

func get_preco(nome):
	for item in estoque:
		if item.name == nome:
			return item.price
	return 0

func calculate_total_purchase_cost() -> int:
	var total_preco = 0
	selected_quantities = _sanitize_selected_quantities()

	for nome in selected_quantities:
		total_preco += int(selected_quantities[nome]) * int(get_preco(str(nome)))

	return total_preco

func calculate_purchase_total() -> int:
	return calculate_total_purchase_cost()

func build_purchase_list_text() -> String:
	selected_quantities = _sanitize_selected_quantities()
	var lines: Array[String] = []
	var total = 0

	for item in estoque:
		var item_id = str(item.name)
		var quantity = get_selected_quantity(item_id)
		if quantity <= 0:
			continue

		var subtotal = int(item.price) * quantity
		total += subtotal
		lines.append("%s x%d - R$ %d" % [item.name, quantity, subtotal])

	if lines.is_empty():
		return "Nenhum item selecionado."

	return "Lista de compra:\n\n%s\n\nTotal: R$ %d" % ["\n".join(lines), total]

func atualizar_ui():
	refresh_stock_ui()

func refresh_stock_ui() -> void:
	var total_itens = 0
	selected_quantities = _sanitize_selected_quantities()

	for nome in selected_quantities:
		total_itens += int(selected_quantities[nome])
		if item_cards.has(nome) and is_instance_valid(item_cards[nome]):
			item_cards[nome].set_selected_quantity(int(selected_quantities[nome]))

	for nome in item_cards:
		if not selected_quantities.has(nome) and is_instance_valid(item_cards[nome]):
			item_cards[nome].set_selected_quantity(0)

	botao_comprar.text = "Comprar selecionados"
	botao_comprar.disabled = total_itens == 0
	refresh_purchase_summary()

func refresh_purchase_summary() -> void:
	if purchase_summary_label == null:
		return
	purchase_summary_label.text = build_purchase_list_text()

func _on_comprar_pressed() -> void:
	confirm_purchase()

func confirm_purchase() -> void:
	selected_quantities = _sanitize_selected_quantities()
	var total_preco = calculate_total_purchase_cost()

	if total_preco <= 0:
		_show_message("Selecione ao menos um item para comprar.")
		refresh_stock_ui()
		return

	var purchase := []
	for item in estoque:
		purchase.append(get_selected_quantity(str(item.name)))

	var result := StockSystem.try_buy_stock_from_script(purchase)
	if not result.get("success", false):
		_show_message(str(result.get("error", "Compra cancelada.")))
		refresh_stock_ui()
		return

	selected_quantities.clear()
	_show_message("Compra realizada com sucesso.")
	draw_estoque(StockSystem.get_stock())
	refresh_purchase_summary()

func _sanitize_selected_quantities() -> Dictionary:
	var valid_quantities := {}
	for nome in selected_quantities:
		var amount = min(max(0, int(selected_quantities[nome])), StockSystem.get_available_space(str(nome)))
		if amount > 0:
			valid_quantities[str(nome)] = amount
	return valid_quantities

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

func _criar_aviso_label() -> void:
	aviso_label = Label.new()
	aviso_label.visible = false
	aviso_label.position = Vector2(25, 38)
	aviso_label.size = Vector2(780, 28)
	add_child(aviso_label)

func _show_message(text: String) -> void:
	if aviso_label == null:
		return
	aviso_label.text = text
	aviso_label.visible = true
	EventBus.emit_signal("send_debug", text)

func _clear_message() -> void:
	if aviso_label == null:
		return
	aviso_label.text = ""
	aviso_label.visible = false
