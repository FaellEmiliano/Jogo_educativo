class_name StockItem

var name : String
var quantity : int
var price : float
var max_quantity : int

func _init(item_name : String, qtd : int, item_price : float, item_max_quantity := 10):
	name = item_name
	quantity = qtd
	price = item_price
	max_quantity = item_max_quantity
