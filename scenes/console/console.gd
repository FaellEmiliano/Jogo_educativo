extends Control
var context
@onready var code_edit: CodeEdit = $Panel/VBoxContainer/EditorFrame/CodeEdit
@onready var status_label: Label = $Panel/VBoxContainer/Header/StatusLabel
@onready var run_button: Button = $Panel/VBoxContainer/Header/Run
@onready var stop_button: Button = $Panel/VBoxContainer/Header/Stop
@onready var new_tab_button: Button = $Panel/VBoxContainer/TabsRow/NewTab
@onready var tab_bar: TabBar = $Panel/VBoxContainer/TabsRow/TabBar
@onready var rename_tab_button: Button = $Panel/VBoxContainer/TabsRow/RenameTab
@onready var delete_tab_button: Button = $Panel/VBoxContainer/TabsRow/DeleteTab

var _script_ids_by_tab: Array[String] = []
var _is_loading_source := false
var _is_refreshing_tabs := false
var _rename_dialog: ConfirmationDialog
var _rename_line_edit: LineEdit
var _delete_dialog: ConfirmationDialog

func _ready() -> void:
	EventBus.update_context.connect(context_updt)
	context = GameManager.current_context
	_setup_tab_controls()
	_setup_dialogs()
	_refresh_tabs()
	_load_active_script_into_editor()
	code_edit.text_changed.connect(_on_code_text_changed)
	code_edit.focus_exited.connect(_on_code_focus_exited)
	_connect_execution_signals()
	_update_status(InterpreterSystem.is_running())

func _setup_tab_controls() -> void:
	new_tab_button.pressed.connect(_on_new_tab_pressed)
	rename_tab_button.pressed.connect(_on_rename_tab_pressed)
	delete_tab_button.pressed.connect(_on_delete_tab_pressed)
	tab_bar.tab_changed.connect(_on_tab_changed)

func _setup_dialogs() -> void:
	_rename_dialog = ConfirmationDialog.new()
	_rename_dialog.title = "Renomear aba"
	_rename_line_edit = LineEdit.new()
	_rename_line_edit.custom_minimum_size = Vector2(280, 28)
	_rename_dialog.add_child(_rename_line_edit)
	_rename_dialog.confirmed.connect(_on_rename_confirmed)
	add_child(_rename_dialog)

	_delete_dialog = ConfirmationDialog.new()
	_delete_dialog.title = "Apagar aba"
	_delete_dialog.dialog_text = "Apagar a aba atual?"
	_delete_dialog.confirmed.connect(_on_delete_confirmed)
	add_child(_delete_dialog)

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
	_save_editor_to_active_script()
	InterpreterSystem.execute_active(context)
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
	if _is_loading_source:
		return
	InterpreterSystem.update_active_source(code_edit.text)

func _on_code_focus_exited() -> void:
	_save_editor_to_active_script()
	Saves.solicitar_save("script_editado")

func set_code_text(text: String) -> void:
	_is_loading_source = true
	code_edit.text = text
	_is_loading_source = false
	InterpreterSystem.update_active_source(text)
	Saves.solicitar_save("script_tutorial")

func get_code_text() -> String:
	return code_edit.text

func _save_editor_to_active_script() -> void:
	if _is_loading_source:
		return
	InterpreterSystem.update_active_source(code_edit.text)

func _load_active_script_into_editor() -> void:
	_is_loading_source = true
	code_edit.text = InterpreterSystem.get_active_source()
	_is_loading_source = false

func _refresh_tabs() -> void:
	_is_refreshing_tabs = true
	_script_ids_by_tab.clear()
	tab_bar.clear_tabs()

	var scripts := InterpreterSystem.get_scripts()
	var active_id := str(InterpreterSystem.get_active_script().get("id", ""))
	var active_index := 0

	for index in range(scripts.size()):
		var script: Dictionary = scripts[index]
		var id := str(script.get("id", ""))
		_script_ids_by_tab.append(id)
		tab_bar.add_tab(str(script.get("title", "Sem nome")))
		if id == active_id:
			active_index = index

	if tab_bar.get_tab_count() > 0:
		tab_bar.current_tab = active_index

	delete_tab_button.disabled = scripts.size() <= 1
	_is_refreshing_tabs = false

func _on_tab_changed(tab: int) -> void:
	if _is_refreshing_tabs:
		return
	if tab < 0 or tab >= _script_ids_by_tab.size():
		return
	_save_editor_to_active_script()
	InterpreterSystem.set_active_script(_script_ids_by_tab[tab])
	_load_active_script_into_editor()

func _on_new_tab_pressed() -> void:
	_save_editor_to_active_script()
	var id := InterpreterSystem.create_script()
	InterpreterSystem.set_active_script(id)
	_refresh_tabs()
	_load_active_script_into_editor()
	Saves.solicitar_save("script_criado")

func _on_rename_tab_pressed() -> void:
	_save_editor_to_active_script()
	_rename_line_edit.text = InterpreterSystem.get_active_script_title()
	_rename_line_edit.select_all()
	_rename_dialog.popup_centered()
	_rename_line_edit.grab_focus()

func _on_rename_confirmed() -> void:
	var active_id := str(InterpreterSystem.get_active_script().get("id", ""))
	InterpreterSystem.rename_script(active_id, _rename_line_edit.text)
	_refresh_tabs()
	Saves.solicitar_save("script_renomeado")

func _on_delete_tab_pressed() -> void:
	if InterpreterSystem.get_scripts().size() <= 1:
		EventBus.emit_signal("send_debug", "Nao e possivel apagar a ultima aba.")
		return
	_save_editor_to_active_script()
	_delete_dialog.popup_centered()

func _on_delete_confirmed() -> void:
	var active_id := str(InterpreterSystem.get_active_script().get("id", ""))
	if not InterpreterSystem.delete_script(active_id):
		EventBus.emit_signal("send_debug", "Nao foi possivel apagar a aba.")
		return
	_refresh_tabs()
	_load_active_script_into_editor()
	Saves.solicitar_save("script_apagado")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if code_edit.has_focus() and not code_edit.get_global_rect().has_point(event.position):
			code_edit.release_focus()
