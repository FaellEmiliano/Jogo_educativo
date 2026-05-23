extends Control


const REPOSITORY_URL := "https://github.com/placeholder/jogo-educativo"

@onready var save_menu: ColorRect = $SaveMenu
@onready var save_summary: Label = $SaveMenu/SavePanel/SaveStack/SaveBox/SaveSummary
@onready var continue_button: Button = $SaveMenu/SavePanel/SaveStack/Continue
@onready var confirm_new_game: ConfirmationDialog = $ConfirmNewGame

var current_save: Dictionary = {}
var has_save := false


func _ready() -> void:
	_load_save_summary()
	save_menu.visible = false


func _load_save_summary() -> void:
	current_save = Saves.carregar()
	has_save = _has_started_save(current_save)
	continue_button.disabled = not has_save

	if not has_save:
		save_summary.text = "Nenhum save encontrado.\n\nComece uma nova jornada na oficina."
		return

	var upgrades: Array = current_save.get("upgrades", [])
	var mechanics: Dictionary = current_save.get("unlocked_mechanics", {})
	var unlocked_count := 0
	for mechanic in mechanics:
		if mechanics[mechanic]:
			unlocked_count += 1

	save_summary.text = "Dinheiro: %d\nUpgrades: %d\nMecanicas liberadas: %d" % [
		int(current_save.get("dinheiro", 0)),
		upgrades.size(),
		unlocked_count
	]


func _has_started_save(save_data: Dictionary) -> bool:
	if int(save_data.get("dinheiro", 0)) > 0:
		return true
	if not save_data.get("upgrades", []).is_empty():
		return true

	var mechanics: Dictionary = save_data.get("unlocked_mechanics", {})
	return bool(mechanics.get("change", false)) or bool(mechanics.get("stock", false))


func _go_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_start_pressed() -> void:
	_load_save_summary()
	save_menu.visible = true


func _on_github_pressed() -> void:
	OS.shell_open(REPOSITORY_URL)


func _on_continue_pressed() -> void:
	_go_to_game()


func _on_new_game_pressed() -> void:
	if has_save:
		confirm_new_game.popup_centered()
		return

	Saves.resetar()
	_go_to_game()


func _on_back_pressed() -> void:
	save_menu.visible = false


func _on_confirm_new_game_confirmed() -> void:
	Saves.resetar()
	_go_to_game()
