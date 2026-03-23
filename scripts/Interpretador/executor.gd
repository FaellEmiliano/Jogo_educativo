extends Node

class_name Executor
var call_stack = []
var functions = {}
var builtins = {}
var execution_stack = []
var pending_signal = null
var last_return_value = null

func push_exec(statements):
	execution_stack.append({
		"statements": statements,
		"index": 0
	})

func _init():
	register_builtin()
	#frame global
	var global_frame = {
		"function": "global",
		"scope_stack": []
	}
	call_stack.append(global_frame)
	push_scope()

func step():
	if execution_stack.is_empty():
		return false
	
	var frame = execution_stack.back()
	
	# tratar sinal pendente
	if pending_signal != null:
		if handle_signal(frame):
			return true
	
	# 🔥 PROGRAM INIT (necessário)
	if frame.get("type") == "program":
		if frame["index"] >= frame["statements"].size():
			execution_stack.pop_back()
			
			if "main" in functions:
				call_function("main", [])
			else:
				push_error("main nao encontrada")
			
			return true
		
		var stmt = frame["statements"][frame["index"]]
		frame["index"] += 1
		
		exec(stmt)
		return true
	
	# FUNCTION
	if frame.get("type") == "function":
		if frame.get("executing_body", false) == false:
			frame["executing_body"] = true
			return true

		# terminou execução
		if execution_stack.back() == frame:
			if frame.get("scope"):
				pop_scope()
			call_stack.pop_back()
			execution_stack.pop_back()
			return true
	
	# 🔥 BLOCK NORMAL
	if frame.get("type", "block") == "block":
		
		if frame["index"] >= frame["statements"].size():
			if frame.get("scope"):
				pop_scope()
			execution_stack.pop_back()
			return true
		
		var stmt = frame["statements"][frame["index"]]
		frame["index"] += 1
		
		var result = exec(stmt)
		if result is ControlSignal.FunctionCallSignal:
			var args = []
			for arg in result.node.args:
				args.append(eval(arg))
			call_function(result.node.name, args)
			return true

		if result != null:
			pending_signal = result
		
		return true
	
	# WHILE
	if frame.get("type") == "while":
		return step_while(frame)
	
	# FOR
	if frame.get("type") == "for":
		return step_for(frame)
	
	return true

func handle_signal(frame):

	# RETURN
	if pending_signal is ControlSignal.ReturnSignal:
		if frame.get("type") == "function":
			
			frame["return_value"] = pending_signal.value  # 🔥 aqui
			last_return_value = frame["return_value"]
			
			if frame.get("scope"):
				pop_scope()
			
			call_stack.pop_back()
			execution_stack.pop_back()
			
			pending_signal = null
			return true

	# BREAK
	if pending_signal is ControlSignal.BreakSignal:
		if frame.get("type") in ["while", "for"]:
			execution_stack.pop_back()
			pending_signal = null
			return true
		else:
			execution_stack.pop_back()
			return false

	# CONTINUE
	if pending_signal is ControlSignal.ContinueSignal:
		if frame.get("type") in ["while", "for"]:
			pending_signal = null
			return true
		else:
			execution_stack.pop_back()
			return false

	return false
func push_scope():
	var frame=call_stack.back()
	frame["scope_stack"].append({})

func pop_scope():
	var frame=call_stack.back()
	frame["scope_stack"].pop_back()

func current_scope():
	return call_stack.back()["scope_stack"].back()

func create_frame(function_name):
	return {"function":function_name,"scope_stack":[]}

func get_var(node):
	var nome = node.name
	var frame = call_stack.back()
	for i in range(frame["scope_stack"].size() - 1, -1, -1):
		if nome in frame["scope_stack"][i]:
			return frame["scope_stack"][i][nome]

	push_error("variavel nao definida: " + nome)
	return null

func declare_var(nome,value):
	current_scope()[nome] = value

func assign_var(node,value):
	var frame = call_stack.back()
	#var
	if node is ASTNodes.IdentifierNode:
		var nome = node.name
		for i in range(frame["scope_stack"].size() - 1, -1, -1):
			if nome in frame["scope_stack"][i]:
				frame["scope_stack"][i][nome] = value
				return
		push_error("variavel nao definida: " + nome)
		return
	#array
	elif node is ASTNodes.ArrayAccessNode:
		var array :Array
		array = get_var(node.array)
		var indexes = node.indexes

		for i in range(indexes.size()-1):
			var idx = eval(indexes[i])
			array = array[idx]

		var last = eval(indexes.back())
		array[last] = value
		return
	push_error("variavel nao definida: " + node.name)
	return
		
func register_builtin():
	builtins["print"] = func(args):
		var _cat_str = ""
		for arg in args:
			_cat_str += str(arg)
		print(_cat_str)
		return null

func exec(node):
	return node.accept_exec(self)

func eval(node):
	return node.accept_eval(self)

func run(program):
	execution_stack.clear()
	pending_signal = null
	last_return_value = null
	
	execution_stack.append({
		"type": "program",
		"statements": program.statements,
		"index": 0
	})

func exec_program(_node):
	# não faz nada, o run() já iniciou
	pass

func exec_block(node):
	push_scope()
	execution_stack.append({
		"type": "block",
		"statements": node.statements,
		"index": 0,
		"scope": true
	})

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
			var operando = node.operando

			var value_inner = get_var(operando)
	
			value_inner +=1
			assign_var(operando,value_inner)
			if node.prefix:
				return value_inner
			else:
				return value_inner -1
		Token.TiposToken.OP_MINUS_MINUS:
			var operando = node.operando
			var value_inner = get_var(operando)
			value_inner -=1
			assign_var(operando,value_inner)
			if node.prefix:
				return value_inner
			else:
				return value_inner +1

func eval_string(node):
	return node.value

func eval_identifier(node):
	return get_var(node)

func exec_var_decl(node):
	var value = null
	if node.value != null:
		value = eval(node.value)
	declare_var(node.name,value)

func exec_array_decl(node):
	var array = create_nd_array(node.sizes)
	current_scope()[node.name] = array

func create_nd_array(sizes,depth = 0):
	var size = eval(sizes[depth])
	var arr = []
	if depth == sizes.size()-1:
		for i in range(size):
			arr.append(0)
	else:
		for i in range(size):
			arr.append(create_nd_array(sizes,depth+1))
	return arr

func eval_array_acess(node):
	var array = get_var(node.array)
	if array == null:
		push_error("array nao existe")
		return null
	for index_node in node.indexes:
		if not (array is Array):
			push_error("tentativa de indexar valor que nao é array")
			return null
		var idx = eval(index_node)
		if idx < 0 or idx >= array.size():
			push_error("Index fora do limite")
			return null
		array = array[idx]
	return array
func eval_assign(node):
	var value = eval(node.value)
	assign_var(node.node,value)
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
	last_return_value = null
	if nome.begins_with("robo_"):
		var command = nome.substr(5)
		Eventos.emit_signal("api_robot", command, args)
		return null

	if nome in builtins:
		return builtins[nome].call(args)

	if nome in functions:
		var func_ = functions[nome]
		var frame = create_frame(nome)
		call_stack.append(frame)
		push_scope()

		for i in range(func_.params.size()):
			var pname = func_.params[i][1]
			declare_var(pname,args[i])

		execution_stack.append({
			"type": "function",
			"node": func_,
			"statements": func_.body.statements,
			"index": 0,
			"scope": true,
			"return_value": null
		})
		return null

func eval_function_call(node):
	var args = []
	for arg in node.args:
		args.append(eval(arg))

	call_function(node.name, args)
	return last_return_value
	
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

func step_while(frame):
	var node = frame["node"]

	if pending_signal is ControlSignal.ContinueSignal:
		pending_signal = null

	if not eval(node.condicao):
		execution_stack.pop_back()
		return true

	push_exec(node.body.statements)
	return true

func step_for(frame):
	var node = frame["node"]

	# INIT (uma vez só)
	if not frame["started"]:
		frame["started"] = true
		
		push_scope()
		frame["scope"] = true  # 🔥 importante
		
		if node.init != null:
			if node.init is ASTNodes.AssignNode:
				eval(node.init)
			else:
				exec(node.init)
		return true

	# CONTINUE
	if pending_signal is ControlSignal.ContinueSignal:
		pending_signal = null
		if node.incremento != null:
			eval(node.incremento)

	# CONDIÇÃO
	if node.condicao != null and not eval(node.condicao):
		if frame["scope"]:
			pop_scope()
		execution_stack.pop_back()
		return true

	# EXECUTA CORPO
	push_exec(node.body.statements)

	# INCREMENTO
	if node.incremento != null:
		eval(node.incremento)

	return true

func exec_while(node):
	execution_stack.append({
		"type": "while",
		"node": node
	})
		
func exec_for(node):
	execution_stack.append({
	"type": "for",
	"node": node,
	"started": false,
	"scope": false
})

func exec_break(_node):
	return ControlSignal.BreakSignal.new()

func exec_continue(_node):
	return ControlSignal.ContinueSignal.new()
