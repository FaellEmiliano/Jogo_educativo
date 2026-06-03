extends MarginContainer

@onready var nome_label: Label = $Button/MarginContainer/HBoxContainer/Info/NomeLabel
@onready var descricao_label: Label = $Button/MarginContainer/HBoxContainer/Info/DescricaoLabel
@onready var preco_button: Button = $Button/MarginContainer/HBoxContainer/ComprarButton

var upgrade_id = ""

func _ready() -> void:
	preco_button.pressed.connect(_on_comprar_pressed)

func setup(id: String, data: Dictionary) -> void:
	upgrade_id = id
	nome_label.text = data.get("nome", "")
	descricao_label.text = data.get("descricao", "")
	preco_button.text = str(data.get("preco", 0))
	toogle_state(UpgradeManager.upgrades_comprados.has(upgrade_id))

func toogle_state(bought: bool) -> void:
	if bought:
		preco_button.text = "Comprado"
		preco_button.disabled = true
	else:
		var preco = int(preco_button.text)
		preco_button.disabled = false
		preco_button.disabled = GameManager.money < preco

func _on_comprar_pressed() -> void:
	UpgradeManager.comprar_upgrade(upgrade_id)
