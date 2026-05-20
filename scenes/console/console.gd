extends Control
var context
@onready var code_edit: CodeEdit = $VBoxContainer/CodeEdit
var running = false


func _ready() -> void:
	EventBus.update_context.connect(context_updt)
	context = GameManager.current_context

func _on_fechar_pressed() -> void:
	get_window().hide()

func _on_minimizar_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().size.y = 37
	else:
		get_window().size.y = 252


func _on_run_pressed() -> void:
	if not running:
		running = true
		InterpreterSystem.execute(code_edit.text,context)
		code_edit.release_focus()
		running = false

func context_updt(ctx):
	context = ctx.env_context
