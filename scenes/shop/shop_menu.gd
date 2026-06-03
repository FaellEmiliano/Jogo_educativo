extends HBoxContainer

const UpgradeItemScene = preload("res://scenes/shop/Item_upgrade.tscn")

@onready var upgrades_container: VBoxContainer = $ColorRect3/Upgrade_table
@onready var toggle_button: Button = $ColorRect2/Button

var itens_por_upgrade = {}
var aberto := false
var _posicao_fechado := Vector2.ZERO
var _posicao_aberto := Vector2.ZERO

func _ready() -> void:
	_posicao_fechado = position
	_posicao_aberto = _posicao_fechado + Vector2(323, 0)
	set_aberto(aberto)
	UpgradeManager.upgrade_liberado.connect(_on_upgrade_liberado)
	UpgradeManager.upgrade_comprado.connect(_on_upgrade_comprado)
	UpgradeManager.upgrades_atualizados.connect(carregar_upgrades_visiveis)
	EventBus.update_money.connect(_on_money_changed)
	carregar_upgrades_visiveis()

func carregar_upgrades_visiveis() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()

	itens_por_upgrade.clear()

	for upgrade in UpgradeManager.get_upgrades_visiveis():
		adicionar_upgrade(upgrade["id"], upgrade["data"], upgrade["comprado"])

func adicionar_upgrade(id: String, data: Dictionary, comprado := false) -> void:
	if itens_por_upgrade.has(id):
		return

	var item = UpgradeItemScene.instantiate()
	upgrades_container.add_child(item)
	item.setup(id, data)
	item.toogle_state(comprado)
	itens_por_upgrade[id] = item

func _on_upgrade_liberado(id: String, data: Dictionary) -> void:
	adicionar_upgrade(id, data)

func _on_upgrade_comprado(id: String) -> void:
	if itens_por_upgrade.has(id):
		itens_por_upgrade[id].toogle_state(true)

func _on_money_changed(_num: int) -> void:
	UpgradeManager.verificar_desbloqueios()
	for id in itens_por_upgrade:
		if not UpgradeManager.upgrades_comprados.has(id):
			itens_por_upgrade[id].toogle_state(false)

func set_aberto(value: bool) -> void:
	if aberto == value and position == ( _posicao_aberto if aberto else _posicao_fechado ):
		return

	aberto = value
	position = _posicao_aberto if aberto else _posicao_fechado
	if toggle_button != null:
		toggle_button.set_pressed_no_signal(aberto)

func is_aberto() -> bool:
	return aberto

func _on_button_toggled(toggled_on: bool) -> void:
	set_aberto(toggled_on)
