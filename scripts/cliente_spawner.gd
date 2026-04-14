extends Node

var chance_cliente = 1
var cliente_na_tela
func _process(delta: float) -> void:
	if not cliente_na_tela:
		spawnar_cliente()

func spawnar_cliente():
	var chance = randi_range(1,1000)
	if chance <= chance_cliente:
		var cliente = preload("res://CEnas/cliente.tscn")
		var cliente_instacia = cliente.instantiate()
		cliente_instacia._hud = $"../HUD"
		var context = compra_cliente([arredondar(randf_range(10.0, 20.0),2),arredondar(randf_range(10.0, 20.0),2)])
		cliente_instacia.context = context
		add_child(cliente_instacia)
		cliente_na_tela = true
		cliente_instacia.run_dialog()
		$"..".start_manual_input()

func compra_cliente(args):
	var soma :float
	for arg in args:
		soma += arg
	var esperado = soma
	return EnvContext.new(args,1,esperado)

func arredondar(valor, casas):
	var fator = pow(10, casas)
	return round(valor * fator) / fator
