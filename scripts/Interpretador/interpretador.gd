extends Node

func _ready():


	# 1. Tokenizar
	var lexer = Lexer.new("""

int soma(int a,int b){
    int x = 100;
    return a + b;
    print(999);
}

int main(){
    print(soma(2,2));
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
