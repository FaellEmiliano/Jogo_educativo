extends Node

signal execution_stopped

var interpretador := Interpreter.new()
var current_execution_context = null
var script_text = ""


func _ready():
	add_child(interpretador)


func execute(code, context):
	set_script_text(str(code))
	if context == null:
		context = EnvContext.new([], 0, [])
	current_execution_context = context
	interpretador.run(code, context)


func stop() -> void:
	if interpretador == null:
		return
	var was_running := is_running()
	interpretador.stop_execution()
	if was_running:
		EventBus.emit_signal("send_debug", "Automação parada")
		emit_signal("execution_stopped")


func is_running() -> bool:
	return interpretador != null and interpretador.executor_flag

func set_script_text(text: String) -> void:
	script_text = text

func get_script_text() -> String:
	return script_text

func get_save_data() -> Dictionary:
	return {
		"script_text": script_text
	}

func load_save_data(data: Dictionary) -> void:
	if data.has("script_text") and data["script_text"] is String:
		script_text = data["script_text"]
