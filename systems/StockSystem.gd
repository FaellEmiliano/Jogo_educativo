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
