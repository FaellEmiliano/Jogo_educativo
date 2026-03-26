extends Node
class_name Builtins

func register(executor):
	executor.register_builtin("print", _print)
	executor.register_builtin("move", _move)
	
func _print(args):
	var str_cat = ""
	for c in args:
		str_cat += str(c)
	print(str_cat)
	return null

func _move(dir):
	Eventos.emit_signal("api_robot","mover",dir)
