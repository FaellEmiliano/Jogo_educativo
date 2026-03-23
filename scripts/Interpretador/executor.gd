extends Node
class_name Executor

var execution_stack = []
var call_stack = []

var is_finished = false

func push_frame(type,node):
	var frame = {
		"type": type,
		"node": node,
		"index": 0,
		"state": {}
	}
	execution_stack.append(frame)

func pop_frame():
	execution_stack.pop_back()

	if execution_stack.is_empty():
		is_finished = true

func current_frame():
	if execution_stack.is_empty():
		return null
	return execution_stack.back()

func load_program(program_node):
	execution_stack.clear()
	call_stack.clear()
	is_finished = false
	
	var global_frame = {
		"name": "global",
		"scope_stack": [{}]
	}
	
	call_stack.append(global_frame)
	
	push_frame("program",program_node)

func step():
	if is_finished:
		return
	
	var frame = current_frame()
	if frame == null:
		is_finished = true
		return
	process_frame(frame)

func process_frame(frame):
	match frame.type:
		"program":
			process_program(frame)
		"block":
			process_block(frame)
		"expression_statement":
			process_expression_statement(frame)
		"assign":
			process_assign(frame)
		"var_decl":
			process_var_decl(frame)
		"if":
			process_if(frame)
		"while":
			process_while(frame)

func process_program(frame):
	match frame.index:
		0:
			push_frame("block",frame.node)
			frame.index = 1
		1:
			pop_frame()

func process_block(frame):
	var statements = frame.node.statements
	
	if frame.index >= statements.size():
		pop_frame()
		return
	var stmt = statements[frame.index]
	frame.index += 1
	push_frame(stmt.type,stmt)

func process_expression_statement(frame):
	match frame.index:
		0:
			var expr = frame.node.expression
			if expr.type == "assign":
				push_frame("assign", expr)
			else:
				var result = eval(expr)
				frame.state["result"] = result
				print("Resultado: ", result)
			frame.index = 1
		1:
			pop_frame()

func eval(node):
	match node.type:
		"number":
			return node.value
		"binary":
			return eval_binary(node)
		"identifier":
			return get_variable(node.name)
		_:
			push_error("Tipo nao suportado: ",node.type)
			return null

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
		Token.TiposToken.OP_MINOR_EQUAL:
			return left <= right
		Token.TiposToken.OP_GREATER_EQUAL:
			return left >= right
		Token.TiposToken.OP_EQUAL_EQUAL:
			return left == right
		Token.TiposToken.OP_NOT_EQUAL:
			return left != right

	push_error("Operador desconhecido: " + str(node.op))
	return null

func get_variable(name):
	for i in range(call_stack.size()-1,-1,-1):
		var frame = call_stack[i]
		var scopes = frame["scope_stack"]

		for j in range(scopes.size() - 1, -1, -1):
			var scope = scopes[j]
			if name in scope:
				return scope[name]

	push_error("Variável não definida: " + name)
	return null

func set_variable(name, value):
	# escreve no escopo atual (topo do scope stack)
	for i in range(call_stack.size() - 1, -1, -1):
		var frame = call_stack[i]
		var scopes = frame["scope_stack"]

		for j in range(scopes.size() - 1, -1, -1):
			var scope = scopes[j]
			if name in scope:
				scope[name] = value
				return

	push_error("Variável não declarada: " + name)
	
func process_assign(frame):
	match frame.index:
		0:
			var value = eval(frame.node.value)
			frame.state["value"] = value
			frame.index = 1
		1:
			var target = frame.node.node
			if target.type == "identifier":
				set_variable(target.name,frame.state["value"])
			else:
				push_error("destino de atrib invalido")
			frame.index = 2
		2:
			pop_frame()

func process_var_decl(frame):
	match frame.index:
		0:
			if frame.node.value != null:
				frame.state["value"] = eval(frame.node.value)
			else:
				frame.state["value"] = null
			frame.index = 1
		1:
			declare_variable(frame.node.name,frame.state["value"])
			frame.index = 2
		2:
			pop_frame()

func declare_variable(name,value):
	var current_frame_ = call_stack.back()
	var current_scope = current_frame_["scope_stack"].back()
	
	if name in current_scope:
		push_error("ja declarada: ",name)
		return
	current_scope[name] = value

func process_if(frame):
	match frame.index:
		0:
			var cond = eval(frame.node.condicao)
			frame.state["cond"] = cond
			frame.index = 1
		1:
			if frame.state["cond"]:
				push_frame("block",frame.node.if_branch)
			elif frame.node.else_branch != null:
				push_frame("block",frame.node.else_branch)
			
			frame.index = 2
		2:
			pop_frame()

func process_while(frame):
	match frame.index:
		0:
			var cond = eval(frame.node.condicao)
			frame.state["cond"] = cond
			frame.index = 1
		1:
			if frame.state["cond"]:
				push_frame("block",frame.node.body)
				frame.index = 2
			else:
				pop_frame()
		2:
			frame.index = 0
