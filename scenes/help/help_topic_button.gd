extends Button

signal topic_selected(topic_id: String)

const FONT_COLOR_OPEN = Color(0.94, 0.84, 0.56)
const FONT_COLOR_LOCKED = Color(0.52, 0.48, 0.39)
const FONT_COLOR_SELECTED = Color(1.0, 0.92, 0.62)
const FONT_COLOR_LOCKED_SELECTED = Color(0.74, 0.64, 0.45)

var topic_id := ""
var _topic_title := ""
var _unlocked := true
var _selected := false

static var _style_open: StyleBoxFlat
static var _style_open_hover: StyleBoxFlat
static var _style_selected: StyleBoxFlat
static var _style_locked: StyleBoxFlat
static var _style_locked_hover: StyleBoxFlat
static var _style_locked_selected: StyleBoxFlat

func _ready() -> void:
	pressed.connect(_on_pressed)

func setup(topic: Dictionary, unlocked: bool, selected: bool, locked_reason: String) -> void:
	topic_id = str(topic.get("id", ""))
	_topic_title = str(topic.get("title", "Tópico"))
	_unlocked = unlocked
	_selected = selected
	focus_mode = Control.FOCUS_ALL
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	clip_text = true
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, 42)
	tooltip_text = "Disponível" if _unlocked else locked_reason
	_update_visuals()

func set_selected(selected: bool) -> void:
	_selected = selected
	_update_visuals()

func set_unlocked(unlocked: bool, locked_reason: String) -> void:
	_unlocked = unlocked
	tooltip_text = "Disponível" if _unlocked else locked_reason
	_update_visuals()

func _on_pressed() -> void:
	topic_selected.emit(topic_id)

func _update_visuals() -> void:
	_ensure_styles()
	var marker := "> " if _selected else "  "
	var state := "ABERTO" if _unlocked else "BLOQUEADO"
	text = "%s%s - %s" % [marker, state, _topic_title]

	if _selected and _unlocked:
		_apply_style(_style_selected, _style_selected, _style_selected, FONT_COLOR_SELECTED)
	elif _selected:
		_apply_style(_style_locked_selected, _style_locked_selected, _style_locked_selected, FONT_COLOR_LOCKED_SELECTED)
	elif _unlocked:
		_apply_style(_style_open, _style_open_hover, _style_selected, FONT_COLOR_OPEN)
	else:
		_apply_style(_style_locked, _style_locked_hover, _style_locked_selected, FONT_COLOR_LOCKED)

func _apply_style(normal: StyleBoxFlat, hover: StyleBoxFlat, pressed_style: StyleBoxFlat, color: Color) -> void:
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", hover)
	add_theme_color_override("font_color", color)
	add_theme_color_override("font_hover_color", color.lightened(0.12))
	add_theme_color_override("font_pressed_color", color)
	add_theme_font_size_override("font_size", 9)

static func _ensure_styles() -> void:
	if _style_open != null:
		return
	_style_open = _make_style(Color(0.07, 0.052, 0.03, 0.94), Color(0.36, 0.27, 0.13))
	_style_open_hover = _make_style(Color(0.12, 0.082, 0.04, 0.98), Color(0.72, 0.52, 0.22))
	_style_selected = _make_style(Color(0.19, 0.12, 0.045, 1.0), Color(0.96, 0.72, 0.3), 3)
	_style_locked = _make_style(Color(0.04, 0.038, 0.034, 0.82), Color(0.16, 0.15, 0.13))
	_style_locked_hover = _make_style(Color(0.06, 0.052, 0.04, 0.9), Color(0.28, 0.24, 0.16))
	_style_locked_selected = _make_style(Color(0.09, 0.07, 0.04, 0.95), Color(0.48, 0.36, 0.16), 2)

static func _make_style(bg: Color, border: Color, left_width := 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = left_width
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = 8
	style.content_margin_top = 7
	style.content_margin_right = 8
	style.content_margin_bottom = 7
	return style
