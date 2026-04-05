extends Node
class_name Builtins
@onready var interpretador: Interpreter = $"../.."
var exec

func register(executor):
	exec = executor
	executor.register_builtin("print", _print)
	executor.register_builtin("send", _send)
func _print(args):
	var str_cat = ""
	for c in args:
		str_cat += str(c)
	print(str_cat)
	return null

func _send(args):
	var id = exec.id
	Eventos.emit_signal("send_output",id,args)

func _catch_input():
	var input_value
	return input_value
	
