extends Node

var chance_cliente = 1
var cliente_na_tela
@onready var game: Control = $".."

func _ready() -> void:
	Eventos.connect("end_client",end_client)
	Eventos.open_client_terminal.connect(open_terminal)
	

func _process(delta: float) -> void:
	if not cliente_na_tela:
		spawnar_cliente()

func spawnar_cliente():
	var chance = randi_range(1,1000)
	if chance <= chance_cliente:
		var cliente = preload("res://CEnas/cliente.tscn")
		var cliente_instacia = cliente.instantiate()
		cliente_instacia._hud = $"../HUD"
		cliente_instacia.context = set_context()
		add_child(cliente_instacia)
		cliente_na_tela = true
		cliente_instacia.run_dialog()

func compra_cliente(args):
	var soma :float
	for arg in args:
		soma += arg
	var esperado = soma
	return [esperado]

func troco(saldo,esperado):
	var troco = saldo - esperado[0]
	return troco

func arredondar(valor, casas):
	var fator = pow(10, casas)
	return round(valor * fator) / fator

func end_client(flag):
	cliente_na_tela = false
	if flag:
		Eventos.emit_signal("update_money",1*game.state_of_game+5)

func set_context():
	if game.state_of_game <= 1:
		var args = [arredondar(randf_range(10.0, 20.0),2),arredondar(randf_range(10.0, 20.0),2)]
		var esperado = compra_cliente(args)
		var context = EnvContext.new(args,1,esperado)
		print(context)
		Eventos.context = context
		Eventos.emit_signal("update_context",context)
		print(context)
		return context
	if game.state_of_game == 2:
		var args = [arredondar(randf_range(10.0, 20.0),2),arredondar(randf_range(10.0, 20.0),2)]
		var esperado = compra_cliente(args)
		var saldo = arredondar(randf_range(40.0, 50.0),2)
		args.append(saldo)
		esperado.append(troco(saldo,esperado))
		var context = EnvContext.new(args,2,esperado)
		Eventos.context = context
		Eventos.emit_signal("update_context",context)
		return context

func open_terminal():
	pass
