extends CodeEdit
var highlighter = CodeHighlighter.new()

func _ready() -> void:
	highlighter.add_keyword_color("if", Color.CYAN)
	highlighter.add_keyword_color("else", Color.CYAN)
	highlighter.add_keyword_color("while", Color.CYAN)
	highlighter.add_keyword_color("for", Color.CYAN)
	highlighter.add_keyword_color("return", Color.CYAN)
	highlighter.add_keyword_color("int", Color.CYAN)
	highlighter.add_keyword_color("float", Color.CYAN)
	highlighter.add_keyword_color("char", Color.CYAN)
	highlighter.add_keyword_color("void", Color.CYAN)
	highlighter.add_color_region("//", "", Color.GREEN, true)
	highlighter.add_color_region('"', '"', Color.YELLOW)

	highlighter.number_color = Color.ORANGE
	highlighter.symbol_color = Color.WHITE

	$".".syntax_highlighter = highlighter
