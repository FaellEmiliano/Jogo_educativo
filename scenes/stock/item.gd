extends Control

@onready var nome: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Nome
@onready var qtd: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Qtd
@onready var texture: TextureRect = $MarginContainer/HBoxContainer/Texture
@onready var preco: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/preco
@onready var add_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Add

signal adicionar(nome)
signal remover(nome)
var local_data
var cart_count := 0

func setup(data):
	local_data = data
	nome.text = data.name
	qtd.text = "%d/%d" % [data.quantity, data.max_quantity]
	preco.text = 'R$ ' + str(data.price)
	_update_add_button()

func set_cart_count(amount: int) -> void:
	cart_count = amount
	_update_add_button()

func _update_add_button() -> void:
	if local_data == null or add_button == null:
		return
	add_button.disabled = cart_count >= StockSystem.get_available_space(local_data.name)

func _on_add_pressed() -> void:
	emit_signal("adicionar", local_data.name)

func _on_minus_pressed() -> void:
	emit_signal("remover", local_data.name)
