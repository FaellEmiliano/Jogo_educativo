extends Node

var chance_cliente = 1
var cliente_na_tela
@onready var game: Control = $".."


func _ready() -> void:
	EventBus.connect("end_client", end_client)
	EventBus.open_client_terminal.connect(open_terminal)


func _process(_delta: float) -> void:
	if not cliente_na_tela:
		spawnar_cliente()


func spawnar_cliente():
	var chance = randi_range(1, 1000)
	if chance <= chance_cliente:
		var cliente = preload("res://scenes/client/cliente.tscn")
		var cliente_instacia = cliente.instantiate()
		cliente_instacia._hud = $"../HUD"
		cliente_instacia.challenge = ChallengeSystem.set_context()
		add_child(cliente_instacia)
		cliente_na_tela = true
		cliente_instacia.run_dialog()


func end_client(flag: bool) -> void:
	cliente_na_tela = false
	if flag:
		var reward = 5
		if GameManager.current_context != null:
			reward = GameManager.current_context.reward
		EventBus.emit_signal("update_money", reward)


func open_terminal():
	pass
