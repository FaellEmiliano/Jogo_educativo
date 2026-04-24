extends Control

var state_of_game :int = 1
var money = 0
@onready var dinheiro_label: Label = $VBoxContainer/ColorRect/VBoxContainer/Dinheiro
@onready var hud = $HUD
@onready var script_menu: VBoxContainer = $ScriptMenu
@onready var shop_menu: HBoxContainer = $ShopMenu


func _ready() -> void:
	Eventos.update_money.connect(update_money)
	Eventos.update_state.connect(new_state_of_game)

	
func update_money(num):
	money += num
	dinheiro_label.text = str(money)


func new_state_of_game(new_state):
	state_of_game = new_state
		
