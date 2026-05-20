extends Node


@onready var continuar: Button = $VBoxContainer/Continuar
@onready var novo_jogo: Button = $VBoxContainer/Novo_jogo


func _ready():
	var dados = Saves.carregar()
	# Jogo novo = sem dinheiro e sem upgrades
	if dados["dinheiro"] == 0 and dados["upgrades"].is_empty():
		continuar.disabled = true


func _on_novo_jogo_pressed() -> void:
	Saves.resetar()
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
