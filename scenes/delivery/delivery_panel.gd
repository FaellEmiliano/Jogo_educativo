extends Control

const Config = preload("res://data/DeliveryConfig.gd")

@onready var money_label: Label = %MoneyLabel
@onready var diamonds_label: Label = %DiamondsLabel
@onready var status_label: Label = %StatusLabel
@onready var normal_count: Label = %NormalCount
@onready var express_count: Label = %ExpressCount
@onready var vip_count: Label = %VipCount
@onready var result_state: Label = %ResultState
@onready var result_normal: Label = %ResultNormal
@onready var result_express: Label = %ResultExpress
@onready var result_vip: Label = %ResultVip
@onready var result_total: Label = %ResultTotal
@onready var result_diamond: Label = %ResultDiamond
@onready var feedback_panel: PanelContainer = %FeedbackPanel
@onready var feedback_label: Label = %FeedbackLabel
@onready var cooldown_panel: PanelContainer = %CooldownPanel
@onready var cooldown_label: Label = %CooldownLabel
@onready var body_grid: GridContainer = %BodyGrid
@onready var category_grid: GridContainer = %CategoryGrid
@onready var close_button: Button = %CloseButton

var _refresh_accumulator := 0.0


func _ready() -> void:
	close_button.pressed.connect(close_panel)
	DeliverySystem.state_changed.connect(refresh)
	DeliverySystem.report_available.connect(_on_report_available)
	DeliverySystem.declaration_accepted.connect(_on_declaration_accepted)
	DeliverySystem.declaration_rejected.connect(_on_declaration_rejected)
	GameManager.diamonds_changed.connect(_on_diamonds_changed)
	EventBus.update_money.connect(_on_money_changed)
	resized.connect(_update_responsive_layout)
	_update_responsive_layout()
	refresh()
	hide()


func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_accumulator += delta
	if _refresh_accumulator >= 0.25:
		_refresh_accumulator = 0.0
		refresh()


func open_panel() -> void:
	show()
	move_to_front()
	refresh()
	close_button.grab_focus()


func close_panel() -> void:
	hide()


func refresh(_unused = null) -> void:
	var view := DeliverySystem.get_view_data()
	money_label.text = "GRANA: R$ %d" % GameManager.money
	diamonds_label.text = "%d / %d" % [GameManager.diamonds, Config.MAX_DIAMONDS]

	var deliveries: Array = view.get("deliveries", [])
	var waiting := int(view.get("state", DeliverySystem.State.LOCKED)) == DeliverySystem.State.WAITING_DECLARATION and deliveries.size() == Config.REPORT_SIZE
	normal_count.text = str(deliveries[0]) if waiting else "--"
	express_count.text = str(deliveries[1]) if waiting else "--"
	vip_count.text = str(deliveries[2]) if waiting else "--"

	_update_status(view)
	_update_last_result(view.get("last_result", {}))
	_update_feedback(view)


func _update_status(view: Dictionary) -> void:
	var current_state := int(view.get("state", DeliverySystem.State.LOCKED))
	match current_state:
		DeliverySystem.State.LOCKED:
			status_label.text = "SISTEMA BLOQUEADO"
			status_label.theme_type_variation = &"WarningLabel"
		DeliverySystem.State.WAITING_DECLARATION:
			if str(view.get("last_feedback_kind", "")) == "rejected":
				status_label.text = "DECLARAÇÃO REJEITADA"
				status_label.theme_type_variation = &"ErrorLabel"
			elif GameManager.diamonds >= Config.MAX_DIAMONDS:
				status_label.text = "MÁXIMO DE DIAMANTES ATINGIDO"
				status_label.theme_type_variation = &"SleepingLabel"
			else:
				status_label.text = "AGUARDANDO DECLARAÇÃO"
				status_label.theme_type_variation = &"CategoryLabel"
		DeliverySystem.State.COOLDOWN:
			status_label.text = "DECLARAÇÃO APROVADA"
			status_label.theme_type_variation = &"SuccessLabel"
		DeliverySystem.State.COMPLETED:
			status_label.text = "JOGO CONCLUÍDO"
			status_label.theme_type_variation = &"SuccessLabel"

	var remaining := int(view.get("cooldown_remaining", 0))
	cooldown_panel.visible = current_state != DeliverySystem.State.WAITING_DECLARATION
	if current_state == DeliverySystem.State.COOLDOWN:
		cooldown_label.text = "PRÓXIMO RELATÓRIO EM %ds" % remaining
		cooldown_label.theme_type_variation = &"SleepingLabel"
	elif current_state == DeliverySystem.State.COMPLETED:
		cooldown_label.text = "Sua loja atingiu o nível máximo de automação."
		cooldown_label.theme_type_variation = &"SuccessLabel"
	else:
		cooldown_label.text = "Compre o upgrade Delivery Online para liberar os relatórios."
		cooldown_label.theme_type_variation = &"WarningLabel"


func _update_last_result(result) -> void:
	if not (result is Dictionary) or result.is_empty():
		result_state.text = "Nenhum relatório aprovado ainda."
		result_state.theme_type_variation = &"SubtitleLabel"
		result_normal.text = "Normal: --"
		result_express.text = "Expressa: --"
		result_vip.text = "VIP: --"
		result_total.text = "Lucro total: --"
		result_diamond.text = "Diamante recebido: --"
		return
	var profits: Array = result.get("profits", [0, 0, 0])
	result_state.text = "DECLARAÇÃO APROVADA"
	result_state.theme_type_variation = &"SuccessLabel"
	result_normal.text = "Normal: +%d moedas" % int(profits[0])
	result_express.text = "Expressa: +%d moedas" % int(profits[1])
	result_vip.text = "VIP: +%d moedas" % int(profits[2])
	result_total.text = "Lucro total: +%d moedas" % int(result.get("total", 0))
	result_diamond.text = "Diamante recebido: +%d" % int(result.get("diamond_awarded", 0))


func _update_feedback(view: Dictionary) -> void:
	var message := str(view.get("last_feedback", ""))
	feedback_panel.visible = not message.is_empty()
	feedback_label.text = message
	var kind := str(view.get("last_feedback_kind", ""))
	if kind == "rejected":
		feedback_label.theme_type_variation = &"ErrorLabel"
	elif kind in ["accepted", "completed"]:
		feedback_label.theme_type_variation = &"SuccessLabel"
	else:
		feedback_label.theme_type_variation = &"WarningLabel"


func _update_responsive_layout(width_override := -1.0) -> void:
	var viewport_width := float(width_override) if float(width_override) >= 0.0 else get_viewport_rect().size.x
	body_grid.columns = 2 if viewport_width >= 900.0 else 1
	category_grid.columns = 3 if viewport_width >= 700.0 else 1


func _on_report_available(_report_id, _deliveries) -> void:
	refresh()


func _on_declaration_accepted(_result) -> void:
	refresh()


func _on_declaration_rejected(_message) -> void:
	refresh()


func _on_diamonds_changed(_value) -> void:
	refresh()


func _on_money_changed(_amount) -> void:
	call_deferred("refresh")
