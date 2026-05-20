extends Control

@onready var nome: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Nome
@onready var qtd: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Qtd
@onready var texture: TextureRect = $MarginContainer/HBoxContainer/Texture
@onready var preco: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/preco

signal adicionar(nome)
signal remover(nome)
var local_data

func setup(data):
	local_data = data
	nome.text = data.name
	qtd.text = str(data.quantity)
	preco.text = 'R$ ' + str(data.price)

func _on_add_pressed() -> void:
	emit_signal("adicionar", local_data.name)

func _on_minus_pressed() -> void:
	emit_signal("remover", local_data.name)
