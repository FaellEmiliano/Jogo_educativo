extends Node

func _ready():


	# 1. Tokenizar
	var lexer = Lexer.new("int soma(int a, int b) {
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

    int x = 10;
    int y = 20;
    int z;

    z = soma(x, y);

    if (z > 20) {
        z = z + 1;
    } else {
        z = z - 1;
    }

    int i = 0;

    while (i < 5) {
        i++;
        if (i == 3) {
            continue;
        }

        z = z + i;
    }

    for (int j = 0; j < 10; j++) {

        if (j == 7) {
            break;
        }

        z = z + j;
    }

    int f = fatorial(5);

    if (f > 100 && z != 0) {
        z = z + f;
    }

    return z;
}")
	var tokens = lexer.tokenize()

	for t in tokens:
		print(Token.TiposToken.keys()[t.type], " : ", t.value)
	
	# 2. parser
	var parser = Parser.new(tokens)
	var ast = parser.parse()
	var printer = ASTPrinter.new()
	printer.print_ast(ast)
