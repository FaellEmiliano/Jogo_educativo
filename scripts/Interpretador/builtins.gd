extends Node
class_name Builtins
@onready var interpretador: Interpreter = $"../.."
var exec

func register(executor):
	exec = executor
	executor.register_builtin("print", _print)
	executor.register_builtin("send", _send)
	executor.register_builtin("input", _catch_input)
func _print(args):
	var str_cat = ""
	for c in args:
		str_cat += str(c)
	print(str_cat)
	return null

func _send(args):
	var id = exec.id
	Eventos.emit_signal("send_output",args)

func _catch_input(_args):
	if exec.input_stack.is_empty():
		push_error("Input stack vazia!")
		return 0
	
	var input_value = exec.input_stack.front()
	exec.input_stack.pop_front()
	return input_value
	
