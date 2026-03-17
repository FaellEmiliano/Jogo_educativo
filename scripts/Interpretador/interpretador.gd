extends Node
class_name Interpreter
@export var debug = false

func run(codigo:String):
	# 1. Tokenizar
	var lexer = Lexer.new(codigo)
	var tokens = lexer.tokenize()
	if debug:
		TokenPrinter.new().print_tokens(tokens)
	# 2. parser
	var parser = Parser.new(tokens)
	var ast = parser.parse()
	if debug:
		parser.print_parser()
	if debug:
		var printer = ASTPrinter.new()
		printer.print_ast(ast)
	#3. executor
	var executor = Executor.new()
	executor.run(ast)
