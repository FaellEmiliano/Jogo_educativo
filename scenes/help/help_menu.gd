extends Control

const HelpTopicsData = preload("res://data/HelpTopics.gd")
const HelpProgressData = preload("res://systems/HelpProgress.gd")
const HelpTopicButton = preload("res://scenes/help/help_topic_button.gd")

@onready var topics_container: VBoxContainer = %TopicsContainer
@onready var progress_label: Label = %ProgressLabel
@onready var category_label: Label = %CategoryLabel
@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var spoiler_button: Button = %SpoilerButton
@onready var hint_panel: PanelContainer = %HintPanel
@onready var hint_label: RichTextLabel = %HintLabel
@onready var close_button: Button = %CloseButton

var _visible_topics: Array = []
var _selected_topic_id := ""
var _current_hint := ""
var _topic_buttons := {}

func _ready() -> void:
	close_button.pressed.connect(close_menu)
	spoiler_button.pressed.connect(_toggle_hint)
	FeatureManager.feature_unlocked.connect(_on_progress_changed)
	UpgradeManager.upgrade_comprado.connect(_on_progress_changed)
	hide()

func open_menu() -> void:
	show()
	move_to_front()
	_refresh_topics()
	close_button.grab_focus()

func close_menu() -> void:
	hide()

func _refresh_topics() -> void:
	_visible_topics = HelpProgressData.get_visible_topics(HelpTopicsData.TOPICS)
	_rebuild_topic_list()
	_update_progress_label()

	if _visible_topics.is_empty():
		_clear_content()
		return

	if not _has_topic(_selected_topic_id):
		_selected_topic_id = str(_visible_topics[0].get("id", ""))
	_show_topic(_selected_topic_id)

func _rebuild_topic_list() -> void:
	for child in topics_container.get_children():
		child.free()
	_topic_buttons.clear()

	var current_category := ""
	for topic in HelpTopicsData.TOPICS:
		var topic_category := str(topic.get("category", "Outros"))
		if topic_category != current_category:
			current_category = topic_category
			topics_container.add_child(_create_category_label(current_category))

		var topic_id := str(topic.get("id", ""))
		var unlocked := HelpProgressData.is_requirement_met(topic.get("requirement", ""))
		var topic_button := HelpTopicButton.new()
		topic_button.setup(topic, unlocked, topic_id == _selected_topic_id, _get_locked_reason(topic))
		topic_button.topic_selected.connect(_show_topic)
		topics_container.add_child(topic_button)
		_topic_buttons[topic_id] = topic_button

func _create_category_label(category_name: String) -> Label:
	var label := Label.new()
	label.text = category_name.to_upper()
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(0.96, 0.73, 0.32))
	label.add_theme_font_size_override("font_size", 9)
	label.custom_minimum_size = Vector2(0, 26)
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return label

func _show_topic(topic_id: String) -> void:
	var topic := _find_topic(topic_id)
	if topic.is_empty():
		return

	_selected_topic_id = topic_id
	_refresh_button_selection()
	category_label.text = str(topic.get("category", ""))
	title_label.text = str(topic.get("title", ""))

	if not HelpProgressData.is_requirement_met(topic.get("requirement", "")):
		status_label.text = "BLOQUEADO"
		status_label.add_theme_color_override("font_color", Color(0.72, 0.58, 0.34))
		body_label.text = _get_locked_body(topic)
		_current_hint = ""
		spoiler_button.visible = false
		_hide_hint()
		body_label.scroll_to_line(0)
		return

	status_label.text = "ABERTO"
	status_label.add_theme_color_override("font_color", Color(0.58, 0.86, 0.62))
	body_label.text = str(topic.get("text", ""))

	_current_hint = str(topic.get("hint", ""))
	spoiler_button.visible = not _current_hint.is_empty()
	_hide_hint()
	body_label.scroll_to_line(0)

func _toggle_hint() -> void:
	if hint_panel.visible:
		_hide_hint()
		return

	hint_label.text = _current_hint
	hint_panel.visible = true
	spoiler_button.text = "FECHAR ANOTAÇÃO"

func _hide_hint() -> void:
	hint_panel.visible = false
	hint_label.text = ""
	spoiler_button.text = "ABRIR ANOTAÇÃO"

func _find_topic(topic_id: String) -> Dictionary:
	for topic in HelpTopicsData.TOPICS:
		if str(topic.get("id", "")) == topic_id:
			return topic
	return {}

func _has_topic(topic_id: String) -> bool:
	return not _find_topic(topic_id).is_empty()

func _clear_content() -> void:
	_selected_topic_id = ""
	category_label.text = ""
	title_label.text = "Nenhum tópico disponível"
	status_label.text = ""
	body_label.text = ""
	_current_hint = ""
	spoiler_button.visible = false
	_hide_hint()

func _on_progress_changed(_arg = null, _extra = null) -> void:
	if visible:
		_refresh_topics()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()

func _refresh_button_selection() -> void:
	for topic_id in _topic_buttons:
		var button = _topic_buttons[topic_id]
		if is_instance_valid(button):
			button.set_selected(str(topic_id) == _selected_topic_id)

func _update_progress_label() -> void:
	if progress_label == null:
		return
	progress_label.text = "%d/%d páginas abertas" % [_visible_topics.size(), HelpTopicsData.TOPICS.size()]

func _get_locked_body(topic: Dictionary) -> String:
	return """[b]Página presa no balcão[/b]
Esse assunto entra no caderno quando a loja liberar: [b]%s[/b].

[b]Por enquanto[/b]
Use os tópicos abertos da lista. Quando o upgrade chegar, esta página aparece completa sem precisar reiniciar o jogo.""" % _get_locked_reason(topic)

func _get_locked_reason(topic: Dictionary) -> String:
	var requirement := str(topic.get("requirement", ""))
	match requirement:
		"troco":
			return "mecânica de troco"
		"sentinela", "loops":
			return "compras variáveis"
		"desconto":
			return "desconto com if"
		"estoque":
			return "sistema de estoque"
		"if":
			return "Conceito: if()"
		"sensor":
			return "Conceito: sensor()"
		"if_sensor":
			return "Conceito: if() e sensor()"
		"", "start":
			return "início do jogo"
		_:
			return requirement
