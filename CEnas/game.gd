extends Control

@onready var hud = $HUD
@onready var scripts_tab: Button = $VBoxContainer/"Scripts tab"
@onready var loja: Button = $VBoxContainer/Loja
var context_window = null

func _ready() -> void:
	Eventos.redraw_buttons.connect(redraw_buttons)

func _on_loja_pressed() -> void:
	var loja_scene = preload("res://CEnas/loja.tscn")
	var loja_instance = loja_scene.instantiate()
	hide_buttons()
	add_child(loja_instance)

func _on_scripts_tab_pressed() -> void:
	var menu = preload("res://CEnas/scripts_menu.tscn")
	hide_buttons()
	var instacia_menu = menu.instantiate()
	add_child(instacia_menu)

func redraw_buttons():
	loja.visible = true
	scripts_tab.visible = true

func hide_buttons():
	loja.visible = false
	scripts_tab.visible = false

func start_manual_input():
	pass
