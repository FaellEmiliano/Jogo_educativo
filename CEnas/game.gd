extends Control

var chance_cliente = 1
var cliente_na_tela
@onready var hud = $HUD
var context_window = null

func _on_loja_pressed() -> void:
	var loja_scene = preload("res://CEnas/loja.tscn")
	var loja_instance = loja_scene.instantiate()
	add_child(loja_instance)

func _process(delta: float) -> void:
	if not cliente_na_tela:
		spawnar_cliente()

func spawnar_cliente():
	var chance = randi_range(1,1000)
	if chance <= chance_cliente:
		var cliente = preload("res://CEnas/cliente.tscn")
		var cliente_instacia = cliente.instantiate()
		cliente_instacia._hud = $HUD
		compra_cliente([randf_range(0,6),randf_range(0,6)])
		add_child(cliente_instacia)
		cliente_na_tela = true
		


func compra_cliente(args):
	var soma :float
	for arg in args:
		soma += arg
	var esperado = soma
	context_window = EnvContext.new(args,1,esperado)
	


func _on_scripts_tab_pressed() -> void:
	var window = preload("res://CEnas/console.tscn")
	var window_instacia = window.instantiate()
	window_instacia.context = context_window
	hud.add_child(window_instacia)
