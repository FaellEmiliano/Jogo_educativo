extends Node
class_name Interpreter
@export var debug = true
var executor = Executor.new()


func _ready():
	# 1. Tokenizar
	var lexer = Lexer.new("""
int soma(int a,int b) {
	return a + b;
}

int x = soma(2, 3)+5;
x;
""")
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
	executor.load_program(ast)
	while not executor.is_finished:
		executor.step()
