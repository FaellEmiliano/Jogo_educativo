extends Node
var estoque = [
	StockItem.new("Arroz", 0, 10),
	StockItem.new("Feijao", 0, 10),
	StockItem.new("Farinha", 0, 10),
	StockItem.new("Morango", 0, 10),
	StockItem.new("Uva", 0, 10),
	StockItem.new("Chocolate", 0, 10)
	]

func get_stock():
	return estoque

func add_item(item_name: String, amount: int) -> void:
	for item in estoque:
		if item.name == item_name:
			item.quantity += amount
			return

func has_items(items: Array) -> bool:
	for requested in items:
		var item_name = str(requested.get("name", ""))
		var amount = int(requested.get("quantity", 0))
		if _get_quantity(item_name) < amount:
			return false
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

func _get_quantity(item_name: String) -> int:
	for item in estoque:
		if item.name == item_name:
			return item.quantity
	return 0

func get_save_data() -> Dictionary:
	var quantities := {}
	for item in estoque:
		quantities[item.name] = item.quantity
	return {
		"quantities": quantities
	}

func load_save_data(data: Dictionary) -> void:
	if not data.has("quantities") or not (data["quantities"] is Dictionary):
		return
	var quantities = data["quantities"]
	for item in estoque:
		if quantities.has(item.name) and (quantities[item.name] is int or quantities[item.name] is float):
			item.quantity = int(quantities[item.name])
