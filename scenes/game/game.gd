extends Control

# game.gd — controlador de UI da tela principal
# Estado real (money, upgrades, unlocked_mechanics) vive em GameManager

@onready var dinheiro_label: Label = $VBoxContainer/ColorRect/VBoxContainer/Dinheiro
@onready var hud = $HUD
@onready var script_menu: VBoxContainer = $ScriptMenu
@onready var shop_menu: HBoxContainer = $ShopMenu


func _ready() -> void:
	# Carrega save e popula GameManager
	var dados = Saves.carregar()
	GameManager.money = dados["dinheiro"]
	GameManager.upgrades = dados["upgrades"]
	for key in dados["unlocked_mechanics"]:
		GameManager.unlocked_mechanics[key] = dados["unlocked_mechanics"][key]

	dinheiro_label.text = str(GameManager.money)
	EventBus.update_money.connect(update_money)


func update_money(num: int) -> void:
	GameManager.money += num
	dinheiro_label.text = str(GameManager.money)
	Saves.salvar(GameManager.money, GameManager.unlocked_mechanics, GameManager.upgrades)
