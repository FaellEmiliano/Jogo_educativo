extends HBoxContainer

const UpgradeItemScene = preload("res://scenes/shop/Item_upgrade.tscn")
const UpgradeData = preload("res://data/UpgradeData.gd")
const TOOLTIP_SIZE := Vector2(320, 190)

@onready var upgrades_container: VBoxContainer = $ColorRect3/UpgradeScroll/Upgrade_table
@onready var toggle_button: Button = $ColorRect2/Button
@onready var tooltip_panel: NinePatchRect = $TooltipLayer/UpgradeTooltip
@onready var tooltip_nome_label: Label = $TooltipLayer/UpgradeTooltip/MarginContainer/VBoxContainer/NomeLabel
@onready var tooltip_descricao_label: Label = $TooltipLayer/UpgradeTooltip/MarginContainer/VBoxContainer/DescricaoLabel
@onready var tooltip_preco_label: Label = $TooltipLayer/UpgradeTooltip/MarginContainer/VBoxContainer/PrecoLabel
@onready var tooltip_status_label: Label = $TooltipLayer/UpgradeTooltip/MarginContainer/VBoxContainer/StatusLabel
@onready var tooltip_requisitos_label: Label = $TooltipLayer/UpgradeTooltip/MarginContainer/VBoxContainer/RequisitosLabel

var itens_por_upgrade = {}
var aberto := false
var _posicao_fechado := Vector2.ZERO
var _posicao_aberto := Vector2.ZERO
var _tooltip_fixado := false
var _tooltip_upgrade_id := ""

func _ready() -> void:
	_posicao_fechado = position
	_posicao_aberto = _posicao_fechado + Vector2(323, 0)
	tooltip_panel.visible = false
	set_aberto(aberto)
	UpgradeManager.upgrade_liberado.connect(_on_upgrade_liberado)
	UpgradeManager.upgrade_comprado.connect(_on_upgrade_comprado)
	UpgradeManager.upgrades_atualizados.connect(carregar_upgrades_visiveis)
	EventBus.update_money.connect(_on_money_changed)
	GameManager.diamonds_changed.connect(_on_diamonds_changed)
	carregar_upgrades_visiveis()

func carregar_upgrades_visiveis() -> void:
	var tooltip_fixado_id = _tooltip_upgrade_id if _tooltip_fixado else ""
	if not _tooltip_fixado:
		_hide_tooltip(true)
	else:
		tooltip_panel.visible = false

	for child in upgrades_container.get_children():
		child.queue_free()

	itens_por_upgrade.clear()

	for upgrade in UpgradeManager.get_upgrades_visiveis():
		adicionar_upgrade(upgrade["id"], upgrade["data"], upgrade["comprado"])

	if tooltip_fixado_id != "":
		if itens_por_upgrade.has(tooltip_fixado_id):
			var item = itens_por_upgrade[tooltip_fixado_id]
			_show_upgrade_tooltip(tooltip_fixado_id, item.upgrade_data, item.global_position, true)
		else:
			_hide_tooltip(true)

func adicionar_upgrade(id: String, data: Dictionary, comprado := false) -> void:
	if itens_por_upgrade.has(id):
		return

	var item = UpgradeItemScene.instantiate()
	upgrades_container.add_child(item)
	item.setup(id, data)
	item.toogle_state(comprado)
	item.tooltip_requested.connect(_on_tooltip_requested)
	item.tooltip_pinned.connect(_on_tooltip_pinned)
	item.tooltip_hidden.connect(_on_tooltip_hidden)
	itens_por_upgrade[id] = item

func _on_upgrade_liberado(id: String, data: Dictionary) -> void:
	if UpgradeManager.upgrades_comprados.has(id):
		return
	adicionar_upgrade(id, data)

func _on_upgrade_comprado(_id: String) -> void:
	carregar_upgrades_visiveis()

func _on_money_changed(_num: int) -> void:
	call_deferred("_refresh_after_money_changed")

func _on_diamonds_changed(_value: int) -> void:
	call_deferred("_refresh_after_money_changed")

func _refresh_after_money_changed() -> void:
	UpgradeManager.verificar_desbloqueios()
	for id in itens_por_upgrade:
		if not UpgradeManager.upgrades_comprados.has(id):
			itens_por_upgrade[id].toogle_state(false)
	if _tooltip_fixado and itens_por_upgrade.has(_tooltip_upgrade_id):
		var item = itens_por_upgrade[_tooltip_upgrade_id]
		_show_upgrade_tooltip(_tooltip_upgrade_id, item.upgrade_data, item.global_position, true)

func set_aberto(value: bool) -> void:
	if aberto == value and position == ( _posicao_aberto if aberto else _posicao_fechado ):
		return

	aberto = value
	position = _posicao_aberto if aberto else _posicao_fechado
	if not aberto:
		_hide_tooltip(true)
	if toggle_button != null:
		toggle_button.set_pressed_no_signal(aberto)

func is_aberto() -> bool:
	return aberto

func _on_button_toggled(toggled_on: bool) -> void:
	set_aberto(toggled_on)

func _on_tooltip_requested(id: String, data: Dictionary, global_pos: Vector2) -> void:
	if _tooltip_fixado:
		if _tooltip_upgrade_id == id:
			_show_upgrade_tooltip(id, data, global_pos, true)
		return
	_show_upgrade_tooltip(id, data, global_pos, false)

func _on_tooltip_pinned(id: String, data: Dictionary, global_pos: Vector2) -> void:
	_show_upgrade_tooltip(id, data, global_pos, true)

func _on_tooltip_hidden() -> void:
	if not _tooltip_fixado:
		_hide_tooltip(false)

func _show_upgrade_tooltip(id: String, data: Dictionary, global_pos: Vector2, fixado: bool) -> void:
	_tooltip_fixado = fixado
	_tooltip_upgrade_id = id

	tooltip_nome_label.text = data.get("nome", "")
	tooltip_descricao_label.text = data.get("tooltip", data.get("descricao", ""))
	tooltip_preco_label.text = "Custa: %s" % UpgradeManager.format_price(id)
	tooltip_status_label.text = "Situação: %s" % _get_tooltip_status(id, data)

	var requisitos = _get_requisitos_text(data)
	tooltip_requisitos_label.visible = requisitos != ""
	tooltip_requisitos_label.text = requisitos

	tooltip_panel.custom_minimum_size = TOOLTIP_SIZE
	tooltip_panel.size = TOOLTIP_SIZE
	tooltip_panel.visible = true
	tooltip_panel.position = _get_tooltip_position(global_pos)

func _hide_tooltip(reset_fixado: bool) -> void:
	tooltip_panel.visible = false
	_tooltip_upgrade_id = ""
	if reset_fixado:
		_tooltip_fixado = false

func _get_tooltip_status(id: String, _data: Dictionary) -> String:
	if UpgradeManager.upgrades_comprados.has(id):
		return "comprado"
	return UpgradeManager.get_missing_currency_text(id)

func _get_requisitos_text(data: Dictionary) -> String:
	var requisitos = data.get("requer", [])
	if requisitos.is_empty():
		return ""

	var nomes = []
	for requisito in requisitos:
		var requisito_id = str(requisito)
		var requisito_data = UpgradeData.UPGRADES.get(requisito_id, {})
		nomes.append(requisito_data.get("nome", requisito_id))
	return "Precisa de: %s" % ", ".join(nomes)

func _get_tooltip_position(global_pos: Vector2) -> Vector2:
	var offset = Vector2(306, 8)
	var viewport_size = get_viewport_rect().size
	var tooltip_size = tooltip_panel.size
	var pos = global_pos + offset

	if pos.x + tooltip_size.x > viewport_size.x:
		pos.x = max(8.0, global_pos.x - tooltip_size.x - 12.0)
	if pos.y + tooltip_size.y > viewport_size.y:
		pos.y = max(8.0, viewport_size.y - tooltip_size.y - 8.0)
	return pos
