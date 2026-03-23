extends Node
class_name Interpreter
@export var debug = false
var acc :float
var speed = 10
var executor = Executor.new()
var execute

func _ready():
	# 1. Tokenizar
	var lexer = Lexer.new("""
int main() {
	int x = 0;
	print(x);
}""")
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
	executor.run(ast)
	execute = true

func _process(delta):
	if execute:
		acc += delta
		var interval = 1.0 / speed
		
		while acc >= interval:
			acc -= interval
			
			if not executor.step():
				execute = false
				break
