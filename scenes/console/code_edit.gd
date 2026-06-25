extends CodeEdit
var highlighter := CodeHighlighter.new()

const COLOR_KEYWORD := Color(0.78, 0.55, 1.0)
const COLOR_TYPE := Color(0.35, 0.82, 1.0)
const COLOR_FUNCTION := Color(0.98, 0.82, 0.46)
const COLOR_STRING := Color(0.62, 0.86, 0.55)
const COLOR_COMMENT := Color(0.48, 0.56, 0.64)
const COLOR_NUMBER := Color(1.0, 0.62, 0.42)
const COLOR_SYMBOL := Color(0.77, 0.82, 0.88)
const COLOR_TEXT := Color(0.86, 0.9, 0.96)
const COLOR_CURRENT_LINE := Color(0.16, 0.19, 0.24, 0.82)
const COLOR_SELECTION := Color(0.25, 0.45, 0.78, 0.46)
const COLOR_CARET := Color(0.95, 0.95, 0.86)
const COLOR_LINE_NUMBER := Color(0.42, 0.48, 0.56)
const COLOR_BRACE_MISMATCH := Color(1.0, 0.32, 0.32)

func _ready() -> void:
	_configure_editor_theme()
	_configure_syntax_highlighter()
	syntax_highlighter = highlighter

func _configure_syntax_highlighter() -> void:
	for keyword in ["if", "else", "while", "for", "return", "break", "continue"]:
		highlighter.add_keyword_color(keyword, COLOR_KEYWORD)

	for type_name in ["int", "float", "char", "void", "bool", "string"]:
		highlighter.add_keyword_color(type_name, COLOR_TYPE)

	for function_name in ["main", "print", "input", "send", "sensor", "get_stock", "buy_stock", "wait"]:
		highlighter.add_keyword_color(function_name, COLOR_FUNCTION)

	highlighter.add_color_region("//", "", COLOR_COMMENT, true)
	highlighter.add_color_region("/*", "*/", COLOR_COMMENT, false)
	highlighter.add_color_region('"', '"', COLOR_STRING)
	highlighter.add_color_region("'", "'", COLOR_STRING)

	highlighter.number_color = COLOR_NUMBER
	highlighter.symbol_color = COLOR_SYMBOL
	highlighter.function_color = COLOR_FUNCTION
	highlighter.member_variable_color = COLOR_TEXT

func _configure_editor_theme() -> void:
	add_theme_color_override("font_color", COLOR_TEXT)
	add_theme_color_override("font_readonly_color", COLOR_TEXT.darkened(0.25))
	add_theme_color_override("font_placeholder_color", COLOR_COMMENT)
	add_theme_color_override("current_line_color", COLOR_CURRENT_LINE)
	add_theme_color_override("selection_color", COLOR_SELECTION)
	add_theme_color_override("caret_color", COLOR_CARET)
	add_theme_color_override("line_number_color", COLOR_LINE_NUMBER)
	add_theme_color_override("font_selected_color", Color.WHITE)
	add_theme_color_override("brace_mismatch_color", COLOR_BRACE_MISMATCH)
	add_theme_color_override("word_highlighted_color", Color(0.35, 0.55, 0.85, 0.28))
