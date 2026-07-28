extends Node
class_name Builtins
@onready var interpretador: Interpreter = $"../.."
var exec

func register(executor):
	exec = executor
	executor.register_builtin("print", _print)
	executor.register_builtin("send", _send)
	executor.register_builtin("input", _catch_input)
	executor.register_builtin("sensor", _catch_sensor)
	executor.register_builtin("get_stock", _get_stock)
	executor.register_builtin("buy_stock", _buy_stock)
	executor.register_builtin("wait", _wait)

func _print(args):
	var str_cat = ""
	for c in args:
		str_cat += _format_print_value(c)
	exec.interpreter.emitir_saida(str_cat)
	return null

func _send(args):
	EventBus.emit_signal("send_output", args)
	return TransactionManager.submit(args)

func _get_stock(args):
	if args.size() != 0:
		exec.interpreter.erro_runtime("get_stock() é chamado sem nada dentro dos parênteses.")
		return null

	var snapshot := StockSystem.get_stock_snapshot()
	return {
		"element_type": "int",
		"dimensions": [snapshot.size()],
		"data": snapshot.duplicate()
	}

func _buy_stock(args):
	if args.size() != 1:
		exec.interpreter.erro_runtime("buy_stock() precisa receber uma lista de compra.")
		return null

	var compra = args[0]
	if not _is_language_array(compra):
		exec.interpreter.erro_runtime("buy_stock() espera um array com %d posições." % StockSystem.get_script_stock_size())
		return null

	var expected_size := StockSystem.get_script_stock_size()
	if compra["dimensions"].size() != 1 or int(compra["dimensions"][0]) != expected_size or compra["data"].size() != expected_size:
		exec.interpreter.erro_runtime("buy_stock() espera um array com %d posições." % expected_size)
		return null

	var result := StockSystem.try_buy_stock_from_script(compra["data"].duplicate())
	if not result.get("success", false):
		exec.interpreter.erro_runtime(str(result.get("error", "Compra cancelada.")))
		return null
	var warning := str(result.get("warning", ""))
	if not warning.is_empty():
		exec.interpreter.emitir_saida(warning)
	return null

func _wait(args):
	if args.size() != 1:
		exec.interpreter.erro_runtime("wait() precisa receber o tempo de espera.")
		return null
	var seconds := maxf(0.0, float(args[0]))
	exec.interpreter.request_sleep(seconds)
	return null

func _is_language_array(value) -> bool:
	return typeof(value) == TYPE_DICTIONARY and value.has("dimensions") and value.has("data") and value["dimensions"] is Array and value["data"] is Array

func _format_print_value(value) -> String:
	if _is_language_array(value):
		return _format_language_array(value)
	return str(value)

func _format_language_array(value: Dictionary) -> String:
	var dimensions: Array = value["dimensions"]
	var data: Array = value["data"]
	if dimensions.is_empty():
		return "[]"
	return _format_array_dimension(data, dimensions, 0, 0)

func _format_array_dimension(data: Array, dimensions: Array, dimension_index: int, offset: int) -> String:
	var parts := []
	var dimension_size := int(dimensions[dimension_index])
	if dimension_index == dimensions.size() - 1:
		for i in range(dimension_size):
			parts.append(_format_print_value(data[offset + i]))
		return "[" + ", ".join(parts) + "]"

	var stride := 1
	for i in range(dimension_index + 1, dimensions.size()):
		stride *= int(dimensions[i])
	for i in range(dimension_size):
		parts.append(_format_array_dimension(data, dimensions, dimension_index + 1, offset + i * stride))
	return "[" + ", ".join(parts) + "]"

func _catch_sensor(args):
	if not FeatureManager.has_feature(FeatureManager.FEATURE_SENSOR):
		exec.interpreter.erro_runtime(FeatureManager.locked_message(FeatureManager.FEATURE_SENSOR))
		return false
	return SensorSystem.get_sensor(args[0])

func _catch_input(_args):
	if TransactionManager.has_active_transaction():
		return TransactionManager.next_input()

	if exec.input_stack.is_empty():
		push_error("Input stack vazia!")
		return 0
	
	var input_value = exec.input_stack.front()
	exec.input_stack.pop_front()
	return input_value
	
