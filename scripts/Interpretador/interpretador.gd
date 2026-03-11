extends Node

func _ready():


	# 1. Tokenizar
	var lexer = Lexer.new("
int fatorial(int n) {
	int resultado = 1;
    while (n > 1) {
        resultado = resultado * n;
        n--;
    }
    return resultado;
}
")
	var tokens = lexer.tokenize()

	for t in tokens:
		print(Token.TiposToken.keys()[t.type], " : ", t.value)
	
	# 2. parser
	var parser = Parser.new(tokens)
	var ast = parser.parse()
	var printer = ASTPrinter.new()
	printer.print_ast(ast)
