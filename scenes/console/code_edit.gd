extends CodeEdit
var highlighter := CodeHighlighter.new()

const COMPLETION_WORDS := [
	"int",
	"float",
	"bool",
	"true",
	"false",
	"if",
	"else",
	"while",
	"for",
	"break",
	"continue",
	"return",
	"main",
	"print",
	"send",
	"input",
	"sensor",
	"get_stock",
	"buy_stock",
	"wait",
	"cliente_na_tela",
]

const COLOR_KEYWORD := Color(0.78, 0.55, 1.0)
const COLOR_TYPE := Color(0.35, 0.82, 1.0)
const COLOR_FUNCTION := Color(0.98, 0.82, 0.46)
const COLOR_STRING := Color(0.62, 0.86, 0.55)
const COLOR_COMMENT := Color(0.48, 0.56, 0.64)
const COLOR_NUMBER := Color(1.0, 0.62, 0.42)
const COLOR_SYMBOL := Color(0.77, 0.82, 0.88)
const COLOR_TEXT := Color(0.86, 0.9, 0.96)

func _ready() -> void:
	_configure_syntax_highlighter()
	_configure_code_completion()
	syntax_highlighter = highlighter

func _request_code_completion(force: bool) -> void:
	var prefix := _get_completion_prefix()
	for word in COMPLETION_WORDS:
		if force or prefix.is_empty() or word.begins_with(prefix):
			add_code_completion_option(_completion_kind_for_word(word), word, word, _completion_color_for_word(word))
	update_code_completion_options(force)

func _configure_code_completion() -> void:
	code_completion_enabled = true
	code_completion_prefixes = _completion_prefixes()

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

func _get_completion_prefix() -> String:
	var line_text := get_line(get_caret_line())
	var column := mini(get_caret_column(), line_text.length())
	var start := column
	while start > 0:
		var previous := line_text.substr(start - 1, 1)
		if not _is_completion_char(previous):
			break
		start -= 1
	return line_text.substr(start, column - start)

func _is_completion_char(character: String) -> bool:
	return character.is_valid_ascii_identifier() or character.is_valid_int() or character == "_"

func _completion_prefixes() -> PackedStringArray:
	var prefixes := PackedStringArray([
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	])
	prefixes.append("_")
	return prefixes

func _completion_kind_for_word(word: String) -> int:
	if word in ["print", "send", "input", "sensor", "get_stock", "buy_stock", "wait", "main"]:
		return KIND_FUNCTION
	if word in ["true", "false"]:
		return KIND_CONSTANT
	if word == "cliente_na_tela":
		return KIND_VARIABLE
	return KIND_PLAIN_TEXT

func _completion_color_for_word(word: String) -> Color:
	if word in ["int", "float", "bool"]:
		return COLOR_TYPE
	if word in ["print", "send", "input", "sensor", "get_stock", "buy_stock", "wait", "main"]:
		return COLOR_FUNCTION
	return COLOR_KEYWORD
