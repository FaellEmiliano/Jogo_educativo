extends Node

var min_spawn_delay = 5.0
var max_spawn_delay = 8.0

var cliente_na_tela = false
var aguardando_proximo_cliente = false
var spawn_bloqueado := false

@onready var game: Control = $".."

var _cliente_scene: PackedScene = preload("res://scenes/Client/cliente.tscn")
var _spawn_timer: Timer

func _ready() -> void:
	EventBus.connect("end_client", end_client)
	EventBus.open_client_terminal.connect(open_terminal)
	UpgradeManager.upgrade_aplicado.connect(_on_upgrade_aplicado)
	_criar_timer()
	var tutorial_data = Saves.get_tutorial_data()
	if not tutorial_data.get("completed", false):
		bloquear_spawn()
	else:
		iniciar_fluxo_cliente()

func _criar_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)

func iniciar_fluxo_cliente() -> void:
	if spawn_bloqueado:
		return

	if cliente_na_tela or aguardando_proximo_cliente:
		return

	if TransactionManager.has_active_transaction():
		return

	aguardando_proximo_cliente = true
	_spawn_timer.start(_calcular_delay_spawn())

func _calcular_delay_spawn() -> float:
	var delay_range = UpgradeManager.get_spawn_delay_range()
	var menor_delay = min(delay_range.x, delay_range.y)
	var maior_delay = max(delay_range.x, delay_range.y)
	return randf_range(menor_delay, maior_delay)

func _on_spawn_timer_timeout() -> void:
	aguardando_proximo_cliente = false

	if spawn_bloqueado:
		return

	if cliente_na_tela:
		return

	if TransactionManager.has_active_transaction():
		iniciar_fluxo_cliente()
		return

	spawnar_cliente()

func spawnar_cliente() -> void:
	if cliente_na_tela or TransactionManager.has_active_transaction():
		return

	var challenge = ChallengeSystem.set_context()
	if challenge == null:
		if FeatureManager.has_feature(FeatureManager.FEATURE_STOCK):
			if StockSystem.try_emergency_restock():
				EventBus.emit_signal("send_debug", "Reposição emergencial: 1 produto adicionado para evitar travamento.")
				EventBus.emit_signal("get_estoque")
				iniciar_fluxo_cliente()
			else:
				_pausar_por_estoque_vazio()
			return
		iniciar_fluxo_cliente()
		return
	_criar_cliente_com_challenge(challenge)

func spawnar_cliente_tutorial() -> void:
	if cliente_na_tela or TransactionManager.has_active_transaction():
		return

	_criar_cliente_com_challenge(ChallengeSystem.generate_sum_challenge())

func spawnar_cliente_debug(type: String) -> bool:
	if cliente_na_tela or TransactionManager.has_active_transaction():
		return false

	if _spawn_timer != null:
		_spawn_timer.stop()
	aguardando_proximo_cliente = false

	var challenge: ChallengeData
	match type:
		"soma":
			challenge = ChallengeSystem.generate_sum_challenge()
		"compra_variavel":
			challenge = ChallengeSystem.generate_variable_purchase_challenge()
		"cliente_ouro":
			challenge = ChallengeSystem.generate_golden_challenge()
		"troco":
			challenge = ChallengeSystem.generate_change_challenge()
		"estoque":
			challenge = ChallengeSystem.generate_stock_challenge()
		_:
			return false

	if challenge == null:
		return false
	_criar_cliente_com_challenge(challenge)
	return true

func bloquear_spawn() -> void:
	spawn_bloqueado = true
	aguardando_proximo_cliente = false
	if _spawn_timer != null:
		_spawn_timer.stop()

func liberar_spawn() -> void:
	spawn_bloqueado = false
	iniciar_fluxo_cliente()

func _pausar_por_estoque_vazio() -> void:
	var mensagem = "Clientes pausados: estoque vazio. Reponha produtos para voltar a atender."
	EventBus.emit_signal("send_debug", mensagem)
	push_warning(mensagem)
	bloquear_spawn()

func _criar_cliente_com_challenge(challenge: ChallengeData) -> void:
	if challenge == null:
		return

	var cliente_instacia = _cliente_scene.instantiate()
	cliente_instacia._hud = $"../HUD"
	cliente_instacia.challenge = challenge
	add_child(cliente_instacia)

	cliente_na_tela = true
	if not TransactionManager.start_transaction(cliente_instacia, cliente_instacia.challenge):
		cliente_instacia.queue_free()
		cliente_na_tela = false
		iniciar_fluxo_cliente()


func end_client(flag: bool) -> void:
	cliente_na_tela = false
	if flag:
		var reward = 5
		if GameManager.current_context != null:
			reward = GameManager.current_context.reward
		reward = UpgradeManager.calcular_recompensa(reward)
		if GameManager.current_context != null and GameManager.current_context.stock_bonus_active:
			reward = max(1, int(round(reward * GameManager.current_context.stock_bonus_multiplier)))
		EventBus.emit_signal("update_money", reward)
	iniciar_fluxo_cliente()

func _on_upgrade_aplicado(_id: String) -> void:
	if aguardando_proximo_cliente and _spawn_timer != null:
		_spawn_timer.stop()
		_spawn_timer.start(_calcular_delay_spawn())


func open_terminal() -> void:
	pass
