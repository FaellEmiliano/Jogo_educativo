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
		"soma": return 5
		"troco": return 10
		_: return 5

# ─── Entry point ─────────────────────────────────────────────────────────────

func set_context() -> ChallengeData:
	if GameManager.unlocked_mechanics["change"]:
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
