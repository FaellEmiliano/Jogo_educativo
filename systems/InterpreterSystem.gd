extends Node

signal execution_stopped

const ScriptWorkspace = preload("res://systems/ScriptWorkspace.gd")

var interpretador := Interpreter.new()
var current_execution_context = null
var script_text = ""
var script_workspace := ScriptWorkspace.new()


func _ready():
	add_child(interpretador)


func execute(code, context):
	set_script_text(str(code))
	if context == null:
		context = EnvContext.new([], 0, [])
	current_execution_context = context
	interpretador.set_source_name(script_workspace.get_active_title())
	interpretador.run(code, context)

func execute_active(context) -> void:
	execute(script_workspace.get_active_source(), context)


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
	script_workspace.update_active_source(text)

func get_script_text() -> String:
	script_text = script_workspace.get_active_source()
	return script_text

func create_script(title: String = "") -> String:
	return script_workspace.create_script(title)

func delete_script(id: String) -> bool:
	var deleted := script_workspace.delete_script(id)
	script_text = script_workspace.get_active_source()
	return deleted

func rename_script(id: String, new_title: String) -> void:
	script_workspace.rename_script(id, new_title)

func set_active_script(id: String) -> void:
	script_workspace.set_active_script(id)
	script_text = script_workspace.get_active_source()

func update_active_source(source: String) -> void:
	set_script_text(source)

func get_active_source() -> String:
	return get_script_text()

func get_active_script() -> Dictionary:
	return script_workspace.get_active_script()

func get_active_script_title() -> String:
	return script_workspace.get_active_title()

func get_scripts() -> Array:
	return script_workspace.scripts.duplicate(true)

func get_script_workspace_data() -> Dictionary:
	return script_workspace.serialize()

func get_save_data() -> Dictionary:
	script_text = script_workspace.get_active_source()
	return {
		"script_text": script_text,
		"script_workspace": script_workspace.serialize()
	}

func load_save_data(data: Dictionary) -> void:
	script_workspace.deserialize(data)
	script_text = script_workspace.get_active_source()
