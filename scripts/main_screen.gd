extends Node


@onready var continuar: Button = $VBoxContainer/Continuar
@onready var novo_jogo: Button = $VBoxContainer/Novo_jogo


func _ready():
	var dados = Saves.carregar()
	if dados["estado"] == 0:
		continuar.disabled = true
	Eventos.dados = dados


func _on_novo_jogo_pressed() -> void:
	Eventos.dados = Saves._save_padrao()
	get_tree().change_scene_to_file("res://CEnas/game.tscn")


func _on_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://CEnas/game.tscn")
