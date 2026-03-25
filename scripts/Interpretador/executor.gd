extends Node
class_name Executor

var execution_stack = []
var call_stack = []

var is_finished = false

const SIGNAL_BREAK = "break"
const SIGNAL_CONTINUE = "continue"
const SIGNAL_RETURN = "return"

func push_frame(type,node):
	var frame = {
		"type": type,
		"node": node,
		"index": 0,
		"state": {}
	}
	execution_stack.append(frame)

func make_signal(type,value = null):
	return {
		"type": type,
		"value": value
	}


func pop_frame():
	#print("frame popado: ",execution_stack.back())
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
	
	var signal_ = process_frame(frame)
	if signal_ != null:
		handle_signal(signal_)

func handle_signal(signal_):
	match signal_.type:
		SIGNAL_BREAK:
			handle_break()
		SIGNAL_CONTINUE:
			handle_continue()
		SIGNAL_RETURN:
			handle_return(signal_)

func process_frame(frame):
	#print(frame)
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
		"break":
			return make_signal(SIGNAL_BREAK)
		"continue":
			return make_signal(SIGNAL_CONTINUE)
		"return":
			return process_return(frame)
		"function_decl":
			process_function_decl(frame)
		"function_call":
			process_function_call(frame)
		"expression":
			process_expression(frame)
		_:
			push_error("nao implementado: ",frame.type)

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
		"bool":
			return node.value
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
			var value_node = frame.node.value
			if value_node.type == "function_call":
				frame.state["waiting_for"] = "function"
				push_frame("function_call",value_node)
				frame.index = 1
				return
				
			var value = eval(frame.node.value)
			frame.state["value"] = value
			frame.index = 2
		1:
			frame.state["value"] = frame.state["function_result"]
			frame.index = 2
		2:
			var target = frame.node.node
			if target.type == "identifier":
				set_variable(target.name,frame.state["value"])
			else:
				push_error("destino de atrib invalido")
			frame.index = 3
		3:
			pop_frame()

func process_var_decl(frame):
	match frame.index:
		0:
			var value_node = frame.node.value
			if value_node != null and has_function_call(value_node):
				frame.state["expr_node"] = value_node
				push_frame("expression",value_node)
				frame.index = 1
				return
			if value_node != null:
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

func handle_break():
	while not execution_stack.is_empty():
		var frame = current_frame()

		pop_frame()

		if frame.type == "while":
			return

	push_error("break usado fora de loop")

func handle_continue():
	while not execution_stack.is_empty():
		var frame = current_frame()

		if frame.type == "while":
			frame.index = 0
			return

		pop_frame()

	push_error("continue usado fora de loop")

func process_return(frame):
	match frame.index:
		0:
			if frame.node.value != null:
				frame.state["value"] = eval(frame.node.value)
			else:
				frame.state["value"] = null
			frame.index = 1
		1:
			return make_signal(SIGNAL_RETURN, frame.state["value"])

func handle_return(signal_):
	var return_value = signal_.value

	while not execution_stack.is_empty():
		var frame = current_frame()

		if frame.type == "function_call":
			frame.state["return_value"] = return_value
			frame.index = 2
			return
			
		pop_frame()

	push_error("return fora de função")

func process_function_decl(frame):
	match frame.index:
		0:
			var fn_obj = {
				"type": "function",
				"name": frame.node.name,
				"params": frame.node.params,
				"body": frame.node.body
			}
			declare_variable(frame.node.name, fn_obj)
			frame.index = 1

		1:
			pop_frame()

func process_function_call(frame):
	match frame.index:
		0:
			var fn = get_variable(frame.node.name)
			if fn == null or fn.type != "function":
				push_error("nao é função: ",frame.node.name)
				return
			frame.state["fn"] = fn
			
			var args = []
			for arg in frame.node.args:
				args.append(eval(arg))
			frame.state["args"] = args
			frame.index = 1
			
		1:
			var fn = frame.state["fn"]
			var args = frame.state["args"]
			var new_frame = {
				"name": fn.name,
				"scope_stack": [{}]
			}
			call_stack.append(new_frame)
			for i in range(fn.params.size()):
				var param_name = fn.params[i][1]
				var value = args[i] if i < args.size() else null
				new_frame["scope_stack"].back()[param_name] = value
			push_frame("block",fn.body)
			frame.index = 2
			return
		2:
			frame.index = 3
		3:
			var result = frame.state.get("return_value")
			call_stack.pop_back()
			deliver_result_to_parent(result)
			
			pop_frame()

func deliver_result_to_parent(value):
	if execution_stack.size() < 2:
		return
	var parent = execution_stack[execution_stack.size()-2]
	parent.state["value"] = value
	parent.state.erase("waiting_for")
	#print("frame pai: ",parent)

func has_function_call(node):
	if node == null:
		return false
	if node.type == "function_call":
		return true
	if node.type == "binary":
		return has_function_call(node.left) or has_function_call(node.right)
	return false

func process_expression(frame):
	var node = frame.node
	print(node.type)
	match node.type:
		"function_call":
			match frame.index:
				0:
					push_frame("function_call",node)
					frame.index = 1
				1:
					deliver_result_to_parent(frame.state["value"])

					pop_frame()
		"binary":
			match frame.index:
				0:
					# resolve left
					if has_function_call(node.left):
						push_frame("expression", node.left)
						frame.index = 1
						return
					else:
						frame.state["left"] = eval(node.left)
						frame.index = 1

				1:
					if not frame.state.has("left"):
						frame.state["left"] = frame.state["value"]

					# resolve right
					if has_function_call(node.right):
						push_frame("expression", node.right)
						frame.index = 2
						return
					else:
						frame.state["right"] = eval(node.right)
						frame.index = 2

				2:
					if not frame.state.has("right"):
						frame.state["right"] = frame.state["value"]

					var l = frame.state["left"]
					var r = frame.state["right"]

					frame.state["result"] = apply_op(node.op, l, r)
					deliver_result_to_parent(frame.state["result"])
					pop_frame()

func apply_op(op,left,right):
	match op.type:
		Token.TiposToken.OP_PLUS:
			return left + right
		Token.TiposToken.OP_MINUS:
			return left - right
		Token.TiposToken.OP_STAR:
			return left * right
		Token.TiposToken.OP_SLASH:
			return left / right
	
	push_error("Operador desconhecido")
	return null
					
