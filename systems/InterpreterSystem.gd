extends Node

var interpretador := Interpreter.new()
var current_execution_context = null


func _ready():
	add_child(interpretador)
func execute(code, context):
	current_execution_context = context
	interpretador.run(code, context)
