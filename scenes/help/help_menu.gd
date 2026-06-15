extends Control

const HelpTopicsData = preload("res://data/HelpTopics.gd")
const HelpProgressData = preload("res://systems/HelpProgress.gd")

@onready var topics_container: VBoxContainer = %TopicsContainer
@onready var category_label: Label = %CategoryLabel
@onready var title_label: Label = %TitleLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var spoiler_button: Button = %SpoilerButton
@onready var hint_panel: PanelContainer = %HintPanel
@onready var hint_label: RichTextLabel = %HintLabel
@onready var close_button: Button = %CloseButton

var _visible_topics: Array = []
var _selected_topic_id := ""
var _current_hint := ""

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

	if _visible_topics.is_empty():
		_clear_content()
		return

	if not _has_visible_topic(_selected_topic_id):
		_selected_topic_id = str(_visible_topics[0].get("id", ""))
	_show_topic(_selected_topic_id)

func _rebuild_topic_list() -> void:
	for child in topics_container.get_children():
		child.free()

	var current_category := ""
	for topic in _visible_topics:
		var topic_category := str(topic.get("category", "Outros"))
		if topic_category != current_category:
			current_category = topic_category
			topics_container.add_child(_create_category_label(current_category))

		var topic_button := Button.new()
		topic_button.text = str(topic.get("title", "Tópico"))
		topic_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		topic_button.focus_mode = Control.FOCUS_ALL
		topic_button.custom_minimum_size = Vector2(0, 38)
		topic_button.pressed.connect(_show_topic.bind(str(topic.get("id", ""))))
		topics_container.add_child(topic_button)

func _create_category_label(category_name: String) -> Label:
	var label := Label.new()
	label.text = category_name.to_upper()
	label.add_theme_color_override("font_color", Color(0.96, 0.73, 0.32))
	label.add_theme_font_size_override("font_size", 12)
	label.custom_minimum_size = Vector2(0, 30)
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return label

func _show_topic(topic_id: String) -> void:
	var topic := _find_topic(topic_id)
	if topic.is_empty():
		return

	_selected_topic_id = topic_id
	category_label.text = str(topic.get("category", ""))
	title_label.text = str(topic.get("title", ""))
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
	spoiler_button.text = "OCULTAR DICA"

func _hide_hint() -> void:
	hint_panel.visible = false
	hint_label.text = ""
	spoiler_button.text = "MOSTRAR DICA"

func _find_topic(topic_id: String) -> Dictionary:
	for topic in _visible_topics:
		if str(topic.get("id", "")) == topic_id:
			return topic
	return {}

func _has_visible_topic(topic_id: String) -> bool:
	return not _find_topic(topic_id).is_empty()

func _clear_content() -> void:
	_selected_topic_id = ""
	category_label.text = ""
	title_label.text = "Nenhum tópico disponível"
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
