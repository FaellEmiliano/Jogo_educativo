extends Node
var executor

func _ready():


	# 1. Tokenizar
	var lexer = Lexer.new("""
		int soma(int a, int b) {
		    int resultado = a + b;
		    return resultado;
		}

		int contador(int limite) {

		    int i = 0;

		    while (i < limite) {

		        if (i == 2) {
					print("dentro do if");
		        }

		        print(i);

		        i = i + 1;
		    }

		    return i;
		}

		int main() {

		    int x = 5;
		    int y = 3;

		    int z = soma(x, y);

			print("resultado da soma:");
		    print(z);

		    int final = contador(4);

			print("contador terminou em:");
		    print(final);

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
