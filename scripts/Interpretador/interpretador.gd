extends Node
var debug = false

func _ready():


	# 1. Tokenizar
	var lexer = Lexer.new("""
int soma(int a, int b) {
    return a + b;
}
int fatorial(int n) {
    int resultado = 1;
    while (n > 1) {
        resultado = resultado * n;
        n--;
    }
    return resultado;
}
int main() {
    int matriz[5][5];
    int i = 0;
    int j = 0;
    int cont = 0;
    // preencher matriz
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            matriz[i][j] = cont;
            cont++;
        }
    }
    // imprimir matriz
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            print(matriz[i][j]);
        }
    }
    // teste de função
    int x = soma(3, 4);
    print(x);
    // teste de while
    int k = 0;
    while (k < 10) {
        if (k == 5) {
            k++;
            continue;
        }
        print(k);
        if (k == 8) {
            break;
        }
        k++;
    }
    // teste de fatorial
    int f = fatorial(5);
    print(f);
    return 0;
}
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
	var executor = Executor.new()
	executor.run(ast)
