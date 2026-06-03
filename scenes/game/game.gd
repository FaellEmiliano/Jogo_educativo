extends Control

# game.gd — controlador de UI da tela principal
# Estado real (money, upgrades, unlocked_mechanics) vive em GameManager
const TutorialOverlayScene = preload("res://scenes/tutorial/tutorial_overlay.tscn")

@onready var dinheiro_label: Label = $VBoxContainer/ColorRect/VBoxContainer/Dinheiro
@onready var hud = $HUD
@onready var script_menu: VBoxContainer = $ScriptMenu
@onready var shop_menu: HBoxContainer = $ShopMenu
@onready var estoque_panel: NinePatchRect = $VBoxContainer/Estoque


func _ready() -> void:
	# Carrega save e popula GameManager
	var dados = Saves.carregar()
	GameManager.money = dados["dinheiro"]
	GameManager.upgrades = dados["upgrades"]
	for key in dados["unlocked_mechanics"]:
		GameManager.unlocked_mechanics[key] = dados["unlocked_mechanics"][key]

	dinheiro_label.text = str(GameManager.money)
	EventBus.update_money.connect(update_money)
	FeatureManager.feature_unlocked.connect(_on_feature_unlocked)
	_atualizar_estado_estoque()
	_instanciar_tutorial_se_necessario()


func update_money(num: int) -> void:
	GameManager.money += num
	dinheiro_label.text = str(GameManager.money)
	Saves.salvar(GameManager.money, GameManager.unlocked_mechanics, GameManager.upgrades)

func _on_feature_unlocked(_feature_id: String) -> void:
	_atualizar_estado_estoque()
	Saves.salvar(GameManager.money, GameManager.unlocked_mechanics, GameManager.upgrades)

func _atualizar_estado_estoque() -> void:
	estoque_panel.visible = FeatureManager.has_feature(FeatureManager.FEATURE_STOCK)

func _instanciar_tutorial_se_necessario() -> void:
	var tutorial_data = Saves.get_tutorial_data()
	if tutorial_data.get("completed", false):
		return

	var tutorial_overlay = TutorialOverlayScene.instantiate()
	add_child(tutorial_overlay)
	tutorial_overlay.setup(self)
