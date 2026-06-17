extends Control

@onready var nome: Label = $MarginContainer/VBoxContainer/InfoRow/Nome
@onready var preco: Label = $MarginContainer/VBoxContainer/InfoRow/Preco
@onready var selected_quantity_label: Label = $MarginContainer/VBoxContainer/QuantityControls/SelectedQuantity
@onready var stock_quantity_label: Label = $MarginContainer/VBoxContainer/StockQuantity
@onready var texture: TextureRect = $MarginContainer/VBoxContainer/Texture
@onready var minus_button: Button = $MarginContainer/VBoxContainer/QuantityControls/Minus
@onready var add_button: Button = $MarginContainer/VBoxContainer/QuantityControls/Add

signal adicionar(nome)
signal remover(nome)
var local_data
var selected_quantity := 0

func setup(data, amount := 0):
	local_data = data
	nome.text = data.name
	preco.text = "R$ " + str(data.price)
	stock_quantity_label.text = "%d/%d" % [data.quantity, data.max_quantity]
	set_selected_quantity(amount)

func set_selected_quantity(amount: int) -> void:
	selected_quantity = max(0, amount)
	selected_quantity_label.text = str(selected_quantity)
	_update_buttons()

func _update_buttons() -> void:
	if local_data == null or add_button == null or minus_button == null:
		return
	var remaining_capacity = StockSystem.get_available_space(local_data.name)
	add_button.disabled = selected_quantity >= remaining_capacity
	minus_button.disabled = selected_quantity <= 0

func _on_add_pressed() -> void:
	emit_signal("adicionar", local_data.name)

func _on_minus_pressed() -> void:
	emit_signal("remover", local_data.name)
