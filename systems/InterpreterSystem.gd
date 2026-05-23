extends Node

var interpretador := Interpreter.new()
var current_execution_context = null


func _ready():
	add_child(interpretador)


func execute(code, context):
	if context == null:
		context = EnvContext.new([], 0, [])
	current_execution_context = context
	interpretador.run(code, context)


func stop() -> void:
	interpretador.executor_flag = false
	interpretador.executor.is_finished = true
	EventBus.emit_signal("send_debug", "Automação parada")


func is_running() -> bool:
	return interpretador != null and interpretador.executor_flag
