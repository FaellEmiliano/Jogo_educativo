extends Node

# ─── Helpers matemáticos ──────────────────────────────────────────────────────

func arredondar(valor, casas):
	var fator = pow(10, casas)
	return round(valor * fator) / fator

func _calcular_total(args) -> float:
	var soma: float = 0.0
	for arg in args:
		soma += arg
	return soma

func _calcular_troco(pagamento: float, total: float) -> float:
	return pagamento - total

# ─── Recompensa por tipo de desafio ──────────────────────────────────────────

func get_reward(type: String) -> int:
	match type:
		"soma": return 8
		"troco": return 16
		"estoque": return 20
		_: return 8

# ─── Entry point ─────────────────────────────────────────────────────────────

func set_context() -> ChallengeData:
	if FeatureManager.has_feature(FeatureManager.FEATURE_STOCK) and randf() < 0.35:
		var stock_challenge = generate_stock_challenge()
		if stock_challenge != null:
			return stock_challenge
	if FeatureManager.has_feature(FeatureManager.FEATURE_CHANGE) and randf() < 0.55:
		return generate_change_challenge()
	return generate_sum_challenge()

# ─── Gerador: soma ────────────────────────────────────────────────────────────

func generate_sum_challenge() -> ChallengeData:
	var challenge = ChallengeData.new()
	challenge.type = "soma"
	challenge.values = [
		arredondar(randf_range(10.0, 20.0), 2),
		arredondar(randf_range(10.0, 20.0), 2)
	]
	challenge.expected_output = [_calcular_total(challenge.values)]
	challenge.reward = get_reward("soma")

	var order = ClientOrder.new()
	order.total = challenge.expected_output[0]
	challenge.order = order

	challenge.env_context = EnvContext.new(
		challenge.values,
		1,
		challenge.expected_output
	)

	GameManager.current_context = challenge
	EventBus.emit_signal("update_context", challenge)
	return challenge

func generate_stock_challenge() -> ChallengeData:
	var requested_items = StockSystem.pick_requestable_items(2)
	if requested_items.is_empty():
		return null

	var challenge = ChallengeData.new()
	challenge.type = "estoque"
	challenge.requires_stock = true
	challenge.requested_items = requested_items
	challenge.values = [
		arredondar(randf_range(14.0, 28.0), 2),
		arredondar(randf_range(14.0, 28.0), 2)
	]
	challenge.expected_output = [_calcular_total(challenge.values)]
	challenge.reward = get_reward("estoque")

	var order = ClientOrder.new()
	order.total = challenge.expected_output[0]
	order.items = requested_items
	challenge.order = order

	challenge.env_context = EnvContext.new(
		challenge.values,
		1,
		challenge.expected_output
	)

	GameManager.current_context = challenge
	EventBus.emit_signal("update_context", challenge)
	return challenge

# ─── Gerador: troco ───────────────────────────────────────────────────────────

func generate_change_challenge() -> ChallengeData:
	var challenge = ChallengeData.new()
	challenge.type = "troco"
	challenge.values = [
		arredondar(randf_range(10.0, 20.0), 2),
		arredondar(randf_range(10.0, 20.0), 2)
	]
	var total = _calcular_total(challenge.values)
	challenge.expected_output = [total]

	challenge.payment = arredondar(randf_range(40.0, 50.0), 2)
	var troco = _calcular_troco(challenge.payment, total)
	challenge.expected_output.append(troco)
	challenge.reward = get_reward("troco")

	var order = ClientOrder.new()
	order.total = total
	order.payment = challenge.payment
	order.change = troco
	challenge.order = order

	var args = challenge.values.duplicate()
	args.append(challenge.payment)
	challenge.env_context = EnvContext.new(
		args,
		2,
		challenge.expected_output
	)

	GameManager.current_context = challenge
	EventBus.emit_signal("update_context", challenge)
	return challenge
