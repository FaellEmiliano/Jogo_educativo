extends Node

func _ready():


	# 1. Tokenizar
	var lexer = Lexer.new("""
	int a(){
		print(b);
	}
int main(){
int b = 0;
a();

	return 0;
}
""")
	var tokens = lexer.tokenize()

	for t in tokens:
		print(Token.TiposToken.keys()[t.type], " : ", t.value)
	
	# 2. parser
	var parser = Parser.new(tokens)
	var ast = parser.parse()
	var printer = ASTPrinter.new()
	printer.print_ast(ast)
	#3. executor
	var executor = Executor.new()
	executor.run(ast)
