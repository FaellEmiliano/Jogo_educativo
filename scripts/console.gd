extends VBoxContainer
var id
@onready var code_edit: CodeEdit = $VBoxContainer/CodeEdit
var interpreter = Interpreter.new()

func _ready() -> void:
	add_child(interpreter)

func _on_fechar_pressed() -> void:
	get_window().hide()

func _on_minimizar_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().size.y = 37
	else:
		get_window().size.y = 252


func _on_run_pressed() -> void:
	interpreter.run(code_edit.text,id)
