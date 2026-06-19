extends Control


const REPOSITORY_URL := "https://github.com/placeholder/jogo-educativo"

@onready var save_menu: ColorRect = $SaveMenu
@onready var save_stack: VBoxContainer = $SaveMenu/SavePanel/SaveStack
@onready var save_title: Label = $SaveMenu/SavePanel/SaveStack/SaveTitle
@onready var legacy_save_box: PanelContainer = $SaveMenu/SavePanel/SaveStack/SaveBox
@onready var legacy_continue_button: Button = $SaveMenu/SavePanel/SaveStack/Continue
@onready var legacy_new_game_button: Button = $SaveMenu/SavePanel/SaveStack/NewGame
@onready var confirm_new_game: ConfirmationDialog = $ConfirmNewGame

var _slot_rows := {}
var _delete_slot := 0


func _ready() -> void:
	Saves.migrate_legacy_save_if_needed()
	_setup_slot_menu()
	save_menu.visible = false


func _setup_slot_menu() -> void:
	save_title.text = "SELECIONAR SAVE"
	legacy_save_box.hide()
	legacy_continue_button.hide()
	legacy_new_game_button.hide()
	confirm_new_game.title = "Apagar save?"
	confirm_new_game.ok_button_text = "Apagar"
	confirm_new_game.dialog_text = "Apagar este slot de save?"
	confirm_new_game.confirmed.connect(_on_delete_save_confirmed)

	for slot in range(1, Saves.SLOT_COUNT + 1):
		var row := _create_slot_row(slot)
		_slot_rows[slot] = row
		save_stack.add_child(row["panel"])
		save_stack.move_child(row["panel"], save_stack.get_child_count() - 2)


func _create_slot_row(slot: int) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 96)
	panel.add_theme_stylebox_override("panel", legacy_save_box.get_theme_stylebox("panel"))

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var summary := Label.new()
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary.theme = legacy_save_box.get_node("SaveSummary").theme
	summary.add_theme_color_override("font_color", Color(0.894118, 0.815686, 0.635294, 1))
	summary.add_theme_font_size_override("font_size", 10)
	summary.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(summary)

	var actions := VBoxContainer.new()
	actions.custom_minimum_size = Vector2(150, 0)
	actions.add_theme_constant_override("separation", 6)
	hbox.add_child(actions)

	var play_button := Button.new()
	play_button.custom_minimum_size = Vector2(150, 36)
	play_button.theme = legacy_continue_button.theme
	play_button.text = "CARREGAR"
	play_button.pressed.connect(func(): _on_slot_play_pressed(slot))
	actions.add_child(play_button)

	var delete_button := Button.new()
	delete_button.custom_minimum_size = Vector2(150, 30)
	delete_button.theme = legacy_new_game_button.theme
	delete_button.text = "APAGAR"
	delete_button.pressed.connect(func(): _on_delete_slot_pressed(slot))
	actions.add_child(delete_button)

	return {
		"panel": panel,
		"summary": summary,
		"play_button": play_button,
		"delete_button": delete_button
	}


func _refresh_slot_menu() -> void:
	for slot in range(1, Saves.SLOT_COUNT + 1):
		var info := Saves.get_slot_info(slot)
		var row: Dictionary = _slot_rows.get(slot, {})
		if row.is_empty():
			continue

		var summary: Label = row["summary"]
		var play_button: Button = row["play_button"]
		var delete_button: Button = row["delete_button"]

		if bool(info.get("corrupted", false)):
			summary.text = "Slot %d\nSave corrompido" % slot
			play_button.text = "NOVO JOGO"
			delete_button.disabled = false
		elif bool(info.get("exists", false)):
			summary.text = "Slot %d\n%s" % [slot, str(info.get("summary", ""))]
			play_button.text = "CONTINUAR"
			delete_button.disabled = false
		else:
			summary.text = "Slot %d\nSlot vazio" % slot
			play_button.text = "NOVO JOGO"
			delete_button.disabled = true


func _go_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_start_pressed() -> void:
	_refresh_slot_menu()
	save_menu.visible = true


func _on_github_pressed() -> void:
	OS.shell_open(REPOSITORY_URL)


func _on_continue_pressed() -> void:
	pass


func _on_new_game_pressed() -> void:
	pass


func _on_back_pressed() -> void:
	save_menu.visible = false


func _on_confirm_new_game_confirmed() -> void:
	pass


func _on_slot_play_pressed(slot: int) -> void:
	Saves.set_current_slot(slot)
	if Saves.has_save(slot):
		Saves.load_game(slot)
	else:
		Saves.resetar()
	_go_to_game()


func _on_delete_slot_pressed(slot: int) -> void:
	if not Saves.has_save(slot):
		return
	_delete_slot = slot
	confirm_new_game.dialog_text = "Apagar o Slot %d? Esta acao nao pode ser desfeita." % slot
	confirm_new_game.popup_centered()


func _on_delete_save_confirmed() -> void:
	if _delete_slot == 0:
		return
	Saves.delete_save(_delete_slot)
	_delete_slot = 0
	_refresh_slot_menu()
