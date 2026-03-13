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

func declare_var(nome,value):
	current_env()[nome] = value

func assign_var(nome,value):
	for i in range(enviroments.size() - 1, -1, -1):
		if nome in enviroments[i]:
			enviroments[i][nome] = value
			return
	push_error("variavel nao definida: " + nome)

func register_builtin():
	builtins["print"] = func(args):
		for a in args:
			print(a)
		return null

func exec(node):
	return node.accept_exec(self)

func eval(node):
	return node.accept_eval(self)

func run(program):
	exec(program)
	if "main" in functions:
		call_function("main",[])
	else:
		push_error("main nao encontrada")

func exec_program(node):
	for stmt in node.statements:
		if stmt is ASTNodes.FunctionDeclNode:
			exec(stmt)

func exec_block(node):
	push_env()
	for stmt in node.statements:
		#print("stmt:", stmt)
		var result = exec(stmt)
		if result != null:
			pop_env()
			return result
	pop_env()

func eval_number(node):
	return node.value

func eval_unary(node):
	var value = eval(node.operando)
	match node.op.type:
		Token.TiposToken.OP_MINUS:
			return -value
		Token.TiposToken.OP_NOT:
			return !value
		Token.TiposToken.OP_PLUS:
			return value
		Token.TiposToken.OP_PLUS_PLUS:
			var nome = node.operando.name

			var value_inner = get_var(nome)
	
			value_inner +=1
			assign_var(nome,value_inner)
			if node.prefix:
				return value_inner
			else:
				return value_inner -1
		Token.TiposToken.OP_MINUS_MINUS:
			var nome = node.operando.name
			var value_inner = get_var(nome)
			value_inner -=1
			assign_var(nome,value_inner)
			if node.prefix:
				return value_inner
			else:
				return value_inner +1

func eval_string(node):
	return node.value

func eval_identifier(node):
	return get_var(node.name)

func exec_var_decl(node):
	var value = null
	if node.value != null:
		value = eval(node.value)
	declare_var(node.name,value)

func eval_assign(node):
	var value = eval(node.value)
	assign_var(node.node.name,value)
	return value

func eval_bool(node):
	return node.value

func eval_binary(node):
	var left = eval(node.left)
	var right = eval(node.right)
	match node.op.type:
		Token.TiposToken.OP_PLUS:
			return left + right
		Token.TiposToken.OP_MINUS:
			return left - right
		Token.TiposToken.OP_STAR:
			return left * right
		Token.TiposToken.OP_SLASH:
			return left / right
		Token.TiposToken.OP_GREATER:
			return left > right
		Token.TiposToken.OP_MINOR:
			return left < right
		Token.TiposToken.OP_EQUAL_EQUAL:
			return left == right
		Token.TiposToken.OP_GREATER_EQUAL:
			return left >= right
		Token.TiposToken.OP_MINOR_EQUAL:
			return left <= right
		Token.TiposToken.OP_NOT_EQUAL:
			return left != right

func exec_function_decl(node):
	functions[node.name] = node

func call_function(nome,args):
	if nome in builtins:
		return builtins[nome].call(args)
	if nome in functions:
		var func_ = functions[nome]
		push_env()
		for i in range(func_.params.size()):
			var pname = func_.params[i][1]
			declare_var(pname,args[i])
		var result = exec(func_.body)
		pop_env()
		if result is ControlSignal.ReturnSignal:
			return result.value
		return null

func eval_function_call(node):
	var args = []
	for arg in node.args:
		args.append(eval(arg))
	return call_function(node.name,args)
	
func exec_expression_statement(node):
	eval(node.expression)

func exec_return(node):
	var value = null
	if node.value != null:
		value = eval(node.value)
	return ControlSignal.ReturnSignal.new(value)

func exec_if(node):
	var cond = eval(node.condicao)
	if cond:
		var result = exec(node.if_branch)
		if result != null:
			return result
	elif node.else_branch != null:
		var result = exec(node.else_branch)
		if result != null:
			return result

func exec_while(node):
	while eval(node.condicao):
		var result = exec(node.body)
		
		if result is ControlSignal.ReturnSignal:
			return result
		if result is ControlSignal.BreakSignal:
			break
		if result is ControlSignal.ContinueSignal:
			continue
		
func exec_for(node):
	push_env()
	if node.init != null:
		exec(node.init)
	while true:
		if node.condicao != null and not eval(node.condicao):
			break
		var result = exec(node.body)
		if result is ControlSignal.ReturnSignal:
			pop_env()
			return result
		if result is ControlSignal.BreakSignal:
			break
		if result is ControlSignal.ContinueSignal:
			if node.incremento != null:
				eval(node.incremento)
			continue
		if node.incremento != null:
			eval(node.incremento)
	pop_env()

func exec_break(_node):
	return ControlSignal.BreakSignal.new()

func exec_continue(_node):
	return ControlSignal.ContinueSignal.new()
