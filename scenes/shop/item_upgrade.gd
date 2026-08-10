extends MarginContainer

signal tooltip_requested(id, data, global_position)
signal tooltip_pinned(id, data, global_position)
signal tooltip_hidden()

@onready var nome_label: Label = $Button/MarginContainer/HBoxContainer/Info/NomeLabel
@onready var descricao_label: Label = $Button/MarginContainer/HBoxContainer/Info/DescricaoLabel
@onready var preco_button: Button = $Button/MarginContainer/HBoxContainer/ComprarButton
@onready var panel: NinePatchRect = $Button

var upgrade_id = ""
var upgrade_data := {}
var comprado := false

func _ready() -> void:
	preco_button.pressed.connect(_on_comprar_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	panel.mouse_entered.connect(_on_mouse_entered)
	panel.mouse_exited.connect(_on_mouse_exited)
	panel.gui_input.connect(_on_gui_input)

func setup(id: String, data: Dictionary) -> void:
	upgrade_id = id
	upgrade_data = data
	nome_label.text = data.get("nome", "")
	descricao_label.text = data.get("categoria", "")
	descricao_label.visible = descricao_label.text != ""
	preco_button.text = "Comprar\n%s" % UpgradeManager.format_price(upgrade_id)
	toogle_state(UpgradeManager.upgrades_comprados.has(upgrade_id))

func toogle_state(bought: bool) -> void:
	comprado = bought
	if bought:
		preco_button.text = "Comprado"
		preco_button.disabled = true
	else:
		preco_button.text = "Comprar\n%s" % UpgradeManager.format_price(upgrade_id)
		preco_button.disabled = not UpgradeManager.can_buy(upgrade_id)

func toggle_state(bought: bool) -> void:
	toogle_state(bought)

func _on_comprar_pressed() -> void:
	_emit_tooltip_pinned()
	UpgradeManager.comprar_upgrade(upgrade_id)

func _on_mouse_entered() -> void:
	tooltip_requested.emit(upgrade_id, upgrade_data, global_position)

func _on_mouse_exited() -> void:
	tooltip_hidden.emit()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_emit_tooltip_pinned()

func _emit_tooltip_pinned() -> void:
	tooltip_pinned.emit(upgrade_id, upgrade_data, global_position)

func _exit_tree() -> void:
	tooltip_hidden.emit()
