extends Node
class_name Interpreter
@export var debug = true
var executor = Executor.new()
var executor_flag


func run(codigo):
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
	executor.load_program(ast)
	executor_flag = true

var steps_per_frame = 1  # controla velocidade

func _process(delta):
	if executor != null and not executor.is_finished and executor_flag:
		for i in range(steps_per_frame):
			executor.step()
			
			if executor.is_finished:
				break
