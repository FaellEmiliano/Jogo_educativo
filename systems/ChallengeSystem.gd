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

func _aplicar_desconto_carrinho(total: float) -> float:
	if total > 50.0:
		return total * 0.9
	return total

# ─── Recompensa por tipo de desafio ──────────────────────────────────────────

func get_reward(type: String) -> int:
	match type:
		"soma": return 8
		"cliente_ouro": return 16
		"compra_variavel": return 12
		"troco": return 16
		"estoque": return 20
		_: return 8

# ─── Entry point ─────────────────────────────────────────────────────────────

func set_context() -> ChallengeData:
	if FeatureManager.has_feature(FeatureManager.FEATURE_DISCOUNT) and randf() < 0.10:
		return generate_golden_challenge()
	if FeatureManager.has_feature(FeatureManager.FEATURE_STOCK) and randf() < 0.35:
		var stock_challenge = generate_stock_challenge()
		if stock_challenge != null:
			return stock_challenge
	if FeatureManager.has_feature(FeatureManager.FEATURE_CHANGE) and randf() < 0.55:
		return generate_change_challenge()
	if FeatureManager.has_feature(FeatureManager.FEATURE_CART) and FeatureManager.has_feature(FeatureManager.FEATURE_DISCOUNT) and randf() < 0.50:
		return generate_variable_purchase_challenge([], true)
	if FeatureManager.has_feature(FeatureManager.FEATURE_CART) and randf() < 0.50:
		return generate_variable_purchase_challenge()
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

# ─── Gerador: cliente de ouro ────────────────────────────────────────────────

func generate_golden_challenge(item_values: Array = []) -> ChallengeData:
	var challenge = ChallengeData.new()
	challenge.type = "cliente_ouro"
	challenge.is_golden = true
	challenge.applies_discount = true
	challenge.values = item_values.duplicate()
	if challenge.values.is_empty():
		challenge.values = [
			arredondar(randf_range(26.0, 40.0), 2),
			arredondar(randf_range(26.0, 40.0), 2)
		]

	var total = _calcular_total(challenge.values)
	var total_com_desconto = arredondar(_aplicar_desconto_carrinho(total), 2)
	challenge.expected_output = [total_com_desconto]
	challenge.reward = get_reward("cliente_ouro")

	var order = ClientOrder.new()
	order.items = challenge.values.duplicate()
	order.total = total_com_desconto
	challenge.order = order

	challenge.env_context = EnvContext.new(
		challenge.values,
		1,
		challenge.expected_output
	)

	GameManager.current_context = challenge
	EventBus.emit_signal("update_context", challenge)
	return challenge

# ─── Gerador: compra variável com sentinela ──────────────────────────────────

func generate_variable_purchase_challenge(item_values: Array = [], apply_discount := false) -> ChallengeData:
	var challenge = ChallengeData.new()
	challenge.type = "compra_variavel"
	challenge.applies_discount = apply_discount
	challenge.values = item_values.duplicate()
	if challenge.values.is_empty():
		var item_count = randi_range(2, 5)
		for _i in range(item_count):
			challenge.values.append(arredondar(randf_range(8.0, 28.0), 2))

	var total = _calcular_total(challenge.values)
	var total_esperado = _aplicar_desconto_carrinho(total) if apply_discount else total
	total_esperado = arredondar(total_esperado, 2)
	challenge.expected_output = [total_esperado]
	challenge.reward = get_reward("compra_variavel")

	var order = ClientOrder.new()
	order.items = challenge.values.duplicate()
	order.total = total_esperado
	challenge.order = order

	var inputs = challenge.values.duplicate()
	inputs.append(-1)
	challenge.env_context = EnvContext.new(
		inputs,
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
