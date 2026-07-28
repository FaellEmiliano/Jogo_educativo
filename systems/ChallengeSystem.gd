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

func _calcular_total_estoque(args) -> float:
	var total := 0.0
	var i := 0
	while i < args.size() - 1:
		total += float(args[i]) * float(args[i + 1])
		i += 2
	return total

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
		"estoque": return 24
		_: return 8

# ─── Entry point ─────────────────────────────────────────────────────────────

func set_context() -> ChallengeData:
	return _build_challenge()

# ─── Pipeline de geração ─────────────────────────────────────────────────────

func _build_challenge(options := {}) -> ChallengeData:
	var challenge = _create_base_challenge(options)
	if challenge == null:
		return null

	_apply_customer_tier(challenge, options)
	_apply_discount_modifier(challenge, options)
	_apply_change_modifier(challenge, options)
	_finalize_challenge(challenge)
	return challenge

func _create_base_challenge(options: Dictionary) -> ChallengeData:
	var forced_base = str(options.get("base", ""))
	if forced_base == "estoque":
		return _create_stock_base()
	if forced_base == "compra_variavel":
		return _create_variable_base()
	if forced_base == "soma":
		return _create_sum_base()

	if FeatureManager.has_feature(FeatureManager.FEATURE_STOCK):
		return _create_stock_base()
	if FeatureManager.has_feature(FeatureManager.FEATURE_CART):
		return _create_variable_base()
	return _create_sum_base()

func _create_sum_base() -> ChallengeData:
	var challenge = ChallengeData.new()
	challenge.type = "soma"
	challenge.values = [
		arredondar(randf_range(10.0, 20.0), 2),
		arredondar(randf_range(10.0, 20.0), 2)
	]
	return challenge

func _create_variable_base() -> ChallengeData:
	var challenge = ChallengeData.new()
	challenge.type = "compra_variavel"
	var item_count = randi_range(3, 5)
	for _i in range(item_count):
		challenge.values.append(arredondar(randf_range(8.0, 28.0), 2))
	return challenge

func _create_stock_base() -> ChallengeData:
	var requested_items = StockSystem.pick_requestable_items(2)
	if requested_items.is_empty():
		return null

	var challenge = ChallengeData.new()
	challenge.type = "estoque"
	challenge.requires_stock = true
	challenge.requested_items = requested_items
	for requested in requested_items:
		for stock_item in StockSystem.get_stock():
			if stock_item.name == requested.get("name", ""):
				var quantity = int(requested.get("quantity", 0))
				challenge.values.append(stock_item.price)
				challenge.values.append(quantity)
				break
	return challenge

func _apply_customer_tier(challenge: ChallengeData, options: Dictionary) -> void:
	var force_golden = bool(options.get("golden", false))
	var can_roll_golden = FeatureManager.has_feature(FeatureManager.FEATURE_DISCOUNT)
	if force_golden or (can_roll_golden and randf() < 0.12):
		challenge.is_golden = true
		challenge.difficulty += 1
		if not challenge.requires_stock:
			for i in range(challenge.values.size()):
				challenge.values[i] = arredondar(float(challenge.values[i]) * 1.25, 2)

func _apply_discount_modifier(challenge: ChallengeData, options: Dictionary) -> void:
	var force_discount = bool(options.get("discount", false))
	if force_discount or FeatureManager.has_feature(FeatureManager.FEATURE_DISCOUNT):
		challenge.applies_discount = true

func _apply_change_modifier(challenge: ChallengeData, options: Dictionary) -> void:
	if bool(options.get("change", false)) or FeatureManager.has_feature(FeatureManager.FEATURE_CHANGE):
		challenge.payment = 1.0

func _finalize_challenge(challenge: ChallengeData) -> void:
	var bruto = _calcular_total_estoque(challenge.values) if challenge.requires_stock else _calcular_total(challenge.values)
	var total_final = bruto
	if challenge.applies_discount:
		total_final = _aplicar_desconto_carrinho(bruto)
	total_final = arredondar(total_final, 2)

	challenge.expected_output = [total_final]
	challenge.reward = _calculate_reward(challenge)
	if StockSystem.is_stock_full():
		challenge.stock_bonus_active = true
		challenge.stock_bonus_multiplier = 1.5

	var order = ClientOrder.new()
	order.total = total_final
	order.items = challenge.requested_items if challenge.requires_stock else challenge.values.duplicate()

	var inputs = challenge.values.duplicate()
	if challenge.type == "compra_variavel" or challenge.requires_stock:
		inputs.append(-1)

	if challenge.payment > 0:
		challenge.payment = arredondar(total_final + randf_range(10.0, 30.0), 2)
		var troco = arredondar(_calcular_troco(challenge.payment, total_final), 2)
		challenge.expected_output.append(troco)
		order.payment = challenge.payment
		order.change = troco
		inputs.append(challenge.payment)

	challenge.order = order
	challenge.env_context = EnvContext.new(
		inputs,
		challenge.expected_output.size(),
		challenge.expected_output
	)

	GameManager.current_context = challenge
	EventBus.emit_signal("update_context", challenge)

func _calculate_reward(challenge: ChallengeData) -> int:
	var reward = get_reward(challenge.type)
	if challenge.payment > 0:
		reward += 4
	if challenge.is_golden:
		reward += 8
	return reward

# ─── Geradores públicos para tutorial/debug ──────────────────────────────────

func generate_sum_challenge() -> ChallengeData:
	return _build_challenge({"base": "soma"})

func generate_golden_challenge(item_values: Array = []) -> ChallengeData:
	var options = {"golden": true}
	if not item_values.is_empty():
		var challenge = ChallengeData.new()
		challenge.type = "compra_variavel" if item_values.size() > 2 else "soma"
		challenge.values = item_values.duplicate()
		_apply_customer_tier(challenge, options)
		_apply_discount_modifier(challenge, {})
		_apply_change_modifier(challenge, {})
		_finalize_challenge(challenge)
		return challenge
	return _build_challenge(options)

func generate_variable_purchase_challenge(item_values: Array = [], apply_discount := false) -> ChallengeData:
	if not item_values.is_empty():
		var challenge = ChallengeData.new()
		challenge.type = "compra_variavel"
		challenge.values = item_values.duplicate()
		_apply_customer_tier(challenge, {})
		_apply_discount_modifier(challenge, {"discount": apply_discount})
		_apply_change_modifier(challenge, {})
		_finalize_challenge(challenge)
		return challenge
	return _build_challenge({"base": "compra_variavel", "discount": apply_discount})

func generate_stock_challenge() -> ChallengeData:
	return _build_challenge({"base": "estoque"})

func generate_change_challenge(apply_discount := false, is_golden := false) -> ChallengeData:
	return _build_challenge({"change": true, "discount": apply_discount, "golden": is_golden})
