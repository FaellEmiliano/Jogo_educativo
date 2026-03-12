extends Node

class_name Executor
var enviroments = []
var functions = {}
var builtins = {}

func _init():
	push_env()
	register_builtin()

func push_env():
	enviroments.append({})

func pop_env():
	enviroments.pop_back()

func current_env():
	return enviroments[enviroments.size()-1]

func get_var(nome):
	for i in range(enviroments.size() - 1, -1, -1):

		if nome in enviroments[i]:
			return enviroments[i][nome]

	push_error("variavel nao definida: " + nome)
	return null
func set_var(nome,value):
	current_env()[nome] = value

func register_builtin():
	builtins["print"] = func(args):
		for a in args:
			print(a)
		return null

func visit(node):
	return node.accept(self)

func run(program):
	visit(program)
	if "main" in functions:
		call_function("main",[])
	else:
		push_error("main nao encontrada")

func visit_program(node):
	for stmt in node.statements:
		if stmt is ASTNodes.FunctionDeclNode:
			visit(stmt)

func visit_block(node):
	for stmt in node.statements:
		var result = visit(stmt)
		if result is ControlReturnSignal.ReturnSignal:
			return result

func visit_number(node):
	return node.value

func visit_string(node):
	return node.value

func visit_identifier(node):
	return get_var(node.name)

func visit_var_decl(node):
	var value = null
	if node.value != null:
		value = visit(node.value)
	set_var(node.name,value)

func visit_assign(node):
	var value = visit(node.value)
	set_var(node.node.name,value)
	return value

func visit_binary(node):
	var left = visit(node.left)
	var right = visit(node.right)
	match node.op.type:
		Token.TiposToken.OP_PLUS:
			return left + right
		Token.TiposToken.OP_MINUS:
			return left - right
		Token.TiposToken.OP_STAR:
			return left * right
		Token.TiposToken.OP_SLASH:
			return left / right

func visit_function_decl(node):
	functions[node.name] = node

func call_function(nome,args):
	if nome in builtins:
		return builtins[nome].call(args)
	if nome in functions:
		var func_ = functions[nome]
		push_env()
		for i in range(func_.params.size()):
			var pname = func_.params[i][1]
			set_var(pname,args[i])
		var result = visit(func_.body)
		pop_env()
		if result is ControlReturnSignal.ReturnSignal:
			return result.value
		return null

func visit_function_call(node):
	var args = []
	for arg in node.args:
		args.append(visit(arg))
	return call_function(node.name,args)
	
func visit_expression_statement(node):
	visit(node.expression)

func visit_return(node):
	var value = null
	if node.value != null:
		value = visit(node.value)
	return ControlReturnSignal.ReturnSignal.new(value)
