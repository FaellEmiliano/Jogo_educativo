extends Control
var context
@onready var code_edit: CodeEdit = $Panel/VBoxContainer/EditorFrame/CodeEdit
@onready var status_label: Label = $Panel/VBoxContainer/Header/StatusLabel
@onready var run_button: Button = $Panel/VBoxContainer/Header/Run
@onready var stop_button: Button = $Panel/VBoxContainer/Header/Stop


func _ready() -> void:
	EventBus.update_context.connect(context_updt)
	context = GameManager.current_context
	code_edit.text = InterpreterSystem.get_script_text()
	code_edit.text_changed.connect(_on_code_text_changed)
	code_edit.focus_exited.connect(_on_code_focus_exited)
	_connect_execution_signals()
	_update_status(InterpreterSystem.is_running())

func _connect_execution_signals() -> void:
	var started := Callable(self, "_on_execution_started")
	var finished := Callable(self, "_on_execution_finished")
	if not InterpreterSystem.interpretador.is_connected("execution_started", started):
		InterpreterSystem.interpretador.connect("execution_started", started)
	if not InterpreterSystem.interpretador.is_connected("execution_finished", finished):
		InterpreterSystem.interpretador.connect("execution_finished", finished)
	if not InterpreterSystem.is_connected("execution_stopped", finished):
		InterpreterSystem.connect("execution_stopped", finished)

func _on_fechar_pressed() -> void:
	get_window().hide()

func _on_minimizar_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().size.y = 37
	else:
		get_window().size.y = 252


func _on_run_pressed() -> void:
	if InterpreterSystem.is_running():
		return
	InterpreterSystem.set_script_text(code_edit.text)
	InterpreterSystem.execute(code_edit.text, context)
	Saves.solicitar_save("script_executado")
	code_edit.release_focus()


func _on_stop_pressed() -> void:
	InterpreterSystem.stop()

func context_updt(ctx):
	context = ctx.env_context

func _on_execution_started() -> void:
	_update_status(true)

func _on_execution_finished() -> void:
	_update_status(false)

func _update_status(is_active: bool) -> void:
	if is_active:
		status_label.text = "RODANDO"
		status_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.55))
		run_button.disabled = true
		stop_button.disabled = false
	else:
		status_label.text = "PARADO"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
		run_button.disabled = false
		stop_button.disabled = true

func _on_code_text_changed() -> void:
	InterpreterSystem.set_script_text(code_edit.text)

func _on_code_focus_exited() -> void:
	InterpreterSystem.set_script_text(code_edit.text)
	Saves.solicitar_save("script_editado")

func set_code_text(text: String) -> void:
	code_edit.text = text
	InterpreterSystem.set_script_text(text)
	Saves.solicitar_save("script_tutorial")

func get_code_text() -> String:
	return code_edit.text

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if code_edit.has_focus() and not code_edit.get_global_rect().has_point(event.position):
			code_edit.release_focus()
