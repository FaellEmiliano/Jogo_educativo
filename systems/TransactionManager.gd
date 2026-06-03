extends Node

var active_client = null
var active_challenge = null
var active_inputs: Array = []
var input_cursor: int = 0
var pending_result: bool = false
var transaction_closing: bool = false


func has_active_transaction() -> bool:
	return active_challenge != null


func start_transaction(client, challenge) -> bool:
	if has_active_transaction():
		return false
	if client == null or challenge == null:
		return false

	active_client = client
	active_challenge = challenge
	active_inputs = challenge.env_context.inputs.duplicate()
	input_cursor = 0
	pending_result = false
	transaction_closing = false

	SensorSystem.set_sensor("cliente_na_tela", true)
	SensorSystem.set_sensor("atendimento_em_andamento", true)

	if active_client.has_signal("result_closed"):
		active_client.result_closed.connect(_finish_transaction, CONNECT_ONE_SHOT)
	if active_client.has_method("show_request_dialog"):
		active_client.show_request_dialog(challenge)

	return true


func next_input() -> Variant:
	if not has_active_transaction() or transaction_closing:
		return 0
	if input_cursor >= active_inputs.size():
		return 0

	var value = active_inputs[input_cursor]
	input_cursor += 1
	return value


func submit(args: Array) -> bool:
	if not has_active_transaction() or transaction_closing:
		return false

	var valores = _normalize_values(args)
	var correto = _validate_values(valores)
	if correto and active_challenge.requires_stock:
		correto = StockSystem.consume_items(active_challenge.requested_items)
	pending_result = correto
	transaction_closing = true
	SensorSystem.set_sensor("cliente_na_tela", false)

	if active_client != null and is_instance_valid(active_client) and active_client.has_method("show_result_dialog"):
		active_client.show_result_dialog(correto, valores)
	else:
		_finish_transaction()

	return correto


func _finish_transaction() -> void:
	if active_challenge == null:
		return

	var result = pending_result
	active_client = null
	active_challenge = null
	active_inputs.clear()
	input_cursor = 0
	pending_result = false
	transaction_closing = false

	SensorSystem.set_sensor("atendimento_em_andamento", false)
	EventBus.emit_signal("end_client", result)


func _normalize_values(args: Array) -> Array:
	var valores = []
	for value in args:
		if value is Array:
			for nested in value:
				valores.append(_to_float(nested))
		else:
			valores.append(_to_float(value))
	return valores


func _to_float(value) -> float:
	var text = str(value).strip_edges().replace(",", ".")
	return float(text)


func _validate_values(valores: Array) -> bool:
	if active_challenge == null:
		return false
	if valores.size() != active_challenge.expected_output.size():
		return false

	for i in range(valores.size()):
		if abs(valores[i] - active_challenge.expected_output[i]) > 0.01:
			return false

	return true
