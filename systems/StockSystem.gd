extends Node
const SCRIPT_STOCK_SIZE := 6

var estoque = [
	StockItem.new("Arroz", 0, 3, 10),
	StockItem.new("Feijao", 0, 4, 10),
	StockItem.new("Farinha", 0, 4, 10),
	StockItem.new("Morango", 0, 5, 10),
	StockItem.new("Uva", 0, 5, 10),
	StockItem.new("Chocolate", 0, 6, 10)
	]

func get_stock():
	return estoque

func get_stock_snapshot() -> Array:
	var snapshot := []
	for item in estoque:
		snapshot.append(int(item.quantity))
	return snapshot

func get_script_stock_size() -> int:
	return SCRIPT_STOCK_SIZE

func try_buy_stock_from_script(compra: Array) -> Dictionary:
	var validation := _validate_stock_purchase(compra)
	if not validation.get("success", false):
		return validation

	var quantities: Array = validation["quantities"]
	var total_cost := int(validation["total_cost"])
	for i in range(quantities.size()):
		estoque[i].quantity += int(quantities[i])

	if total_cost > 0:
		EventBus.emit_signal("update_money", -total_cost)
	EventBus.emit_signal("get_estoque")
	return {"success": true, "error": ""}

func add_item(item_name: String, amount: int) -> int:
	for item in estoque:
		if item.name == item_name:
			var added = min(max(amount, 0), get_available_space(item_name))
			item.quantity += added
			return added
	return 0

func is_stock_full() -> bool:
	if estoque.is_empty():
		return false
	for item in estoque:
		if item.quantity < item.max_quantity:
			return false
	return true

func is_item_full(item_name: String) -> bool:
	return get_available_space(item_name) <= 0

func get_available_space(item_name: String) -> int:
	for item in estoque:
		if item.name == item_name:
			return max(0, item.max_quantity - item.quantity)
	return 0

func has_items(items: Array) -> bool:
	for requested in items:
		var item_name = str(requested.get("name", ""))
		var amount = int(requested.get("quantity", 0))
		if _get_quantity(item_name) < amount:
			return false
	return true

func has_any_items() -> bool:
	for item in estoque:
		if item.quantity > 0:
			return true
	return false

func try_emergency_restock() -> bool:
	if has_any_items() or GameManager.money > 0:
		return false
	if estoque.is_empty():
		return false
	estoque[0].quantity = min(estoque[0].quantity + 1, estoque[0].max_quantity)
	Saves.solicitar_save("estoque_emergencial")
	return true

func consume_items(items: Array) -> bool:
	if not has_items(items):
		return false
	for requested in items:
		var item_name = str(requested.get("name", ""))
		var amount = int(requested.get("quantity", 0))
		for item in estoque:
			if item.name == item_name:
				item.quantity -= amount
				break
	Saves.solicitar_save("estoque_consumido")
	EventBus.emit_signal("get_estoque")
	return true

func pick_requestable_items(max_kinds: int) -> Array:
	var available = []
	for item in estoque:
		if item.quantity > 0:
			available.append(item)
	if available.is_empty():
		return []

	available.shuffle()
	var requested = []
	var kinds = min(max_kinds, available.size())
	for i in range(kinds):
		var item = available[i]
		requested.append({
			"name": item.name,
			"quantity": randi_range(1, min(2, item.quantity))
		})
	return requested

func _validate_stock_purchase(compra: Array) -> Dictionary:
	if compra.size() != SCRIPT_STOCK_SIZE or estoque.size() != SCRIPT_STOCK_SIZE:
		return _stock_purchase_error("buy_stock(): esperado array de tamanho %d." % SCRIPT_STOCK_SIZE)

	var quantities := []
	var total_cost := 0
	for i in range(SCRIPT_STOCK_SIZE):
		var value = compra[i]
		if not (value is int or value is float):
			return _stock_purchase_error("buy_stock(): quantidade invalida no indice %d." % i)
		if float(value) != float(int(value)):
			return _stock_purchase_error("buy_stock(): quantidade precisa ser inteira no indice %d." % i)

		var amount := int(value)
		if amount < 0:
			return _stock_purchase_error("buy_stock(): quantidade negativa no indice %d." % i)
		if int(estoque[i].quantity) + amount > int(estoque[i].max_quantity):
			return _stock_purchase_error("buy_stock(): compra ultrapassa o estoque maximo no indice %d." % i)

		quantities.append(amount)
		total_cost += amount * int(estoque[i].price)

	if GameManager.money < total_cost:
		return _stock_purchase_error("buy_stock(): dinheiro insuficiente para realizar a compra.")

	return {
		"success": true,
		"error": "",
		"quantities": quantities,
		"total_cost": total_cost
	}

func _stock_purchase_error(message: String) -> Dictionary:
	return {
		"success": false,
		"error": message
	}

func _get_quantity(item_name: String) -> int:
	for item in estoque:
		if item.name == item_name:
			return item.quantity
	return 0

func get_save_data() -> Dictionary:
	var quantities := {}
	var max_quantities := {}
	for item in estoque:
		quantities[item.name] = item.quantity
		max_quantities[item.name] = item.max_quantity
	return {
		"quantities": quantities,
		"max_quantities": max_quantities
	}

func load_save_data(data: Dictionary) -> void:
	if not data.has("quantities") or not (data["quantities"] is Dictionary):
		return
	var quantities = data["quantities"]
	var max_quantities = data.get("max_quantities", {})
	for item in estoque:
		if max_quantities is Dictionary and max_quantities.has(item.name) and (max_quantities[item.name] is int or max_quantities[item.name] is float):
			item.max_quantity = max(1, int(max_quantities[item.name]))
		if quantities.has(item.name) and (quantities[item.name] is int or quantities[item.name] is float):
			item.quantity = clamp(int(quantities[item.name]), 0, item.max_quantity)
		else:
			item.quantity = 0
