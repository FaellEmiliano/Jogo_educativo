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
func _print(args):
	var str_cat = ""
	for c in args:
		str_cat += str(c)
	exec.interpreter.emitir_saida(str_cat)
	return null

func _send(args):
	EventBus.emit_signal("send_output", args)
	return TransactionManager.submit(args)

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
	
