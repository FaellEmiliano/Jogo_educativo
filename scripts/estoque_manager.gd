extends Node
@onready var hud: CanvasLayer = $"../HUD"
var estoque = [
	{"name": "Arroz","qtd": 0,"preco": 10},
	{"name": "Feijao","qtd": 0,"preco": 10},
	{"name": "Farinha","qtd": 0,"preco": 10},
	{"name": "Morango","qtd": 0,"preco": 10},
	{"name": "Uva","qtd": 0,"preco": 10},
	{"name": "Chocolate","qtd": 0,"preco": 10},]

func _ready() -> void:
	Eventos.get_estoque.connect(send_estoque)

func send_estoque():
	Eventos.emit_signal("send_estoque",estoque)

func _on_button_pressed() -> void:
	var estoque_scene = preload("res://CEnas/estoque.tscn").instantiate()
	hud.add_child(estoque_scene)
	
