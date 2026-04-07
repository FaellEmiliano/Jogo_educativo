extends Node
class_name Executor

var id
var input_stack

var execution_stack = []
var call_stack = []
var builtins = {}

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

func current_env():
	return call_stack.back()

func push_scope():
	current_env()["scope_stack"].append({})

func pop_scope():
	current_env()["scope_stack"].pop_back()

func current_scope():
	var scopes = current_env()["scope_stack"]
	return scopes[scopes.size() - 1]

func register_builtin(name,fn):
	builtins[name] = fn

func load_program(program_node,id,input_stack):
	self.input_stack = input_stack.duplicate()
	self.id = id
	execution_stack.clear()
	call_stack.clear()
	is_finished = false
	var builtins_obj = Builtins.new()
	builtins_obj.register(self)
	
	var global_frame = {
		"name": "global",
		"scope_stack": [{}],
		"parent": null
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
	#print("frame processado: ",frame)
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
		"for":
			process_for(frame)
		"global_block":
			process_global_block(frame)
		"array_decl":
			process_array_decl(frame)
		_:
			push_error("nao implementado: ",frame.type)

func process_program(frame):
	match frame.index:
		0:
			# registrar tudo primeiro
			push_frame("global_block", frame.node)
			frame.index = 1
			return

		1:
			# chamar main
			var main_fn = get_variable("main")

			if main_fn == null:
				push_error("função main não encontrada")
				pop_frame()
				return

			push_frame("function_call", ASTNodes.FunctionCallNode.new("main", []))
			frame.index = 2

		2:
			pop_frame()

func process_block(frame):
	var statements = frame.node.statements

	match frame.index:
		0:
			push_scope()
			frame.index = 1

		1:
			if frame.state.get("initialized") != true:
				frame.state["initialized"] = true

			if frame.state.get("i") == null:
				frame.state["i"] = 0

			if frame.state["i"] >= statements.size():
				frame.index = 2
				return

			var stmt = statements[frame.state["i"]]
			frame.state["i"] += 1
			push_frame(stmt.type, stmt)

		2:
			pop_scope()
			pop_frame()

func process_expression_statement(frame):
	match frame.index:
		0:
			var expr = frame.node.expression
			#print("expressao tipo: ",expr.type)
			
			if expr.type == "assign":
				push_frame("assign", expr)
			elif expr.type == "function_call":
				push_frame("function_call", expr)
			else:
				push_frame("expression", expr)
			frame.index = 1
		1:
			var result = frame.state.get("value")
			#print("resultado: ",result)
			pop_frame()

func eval(node)->Variant:
	match node.type:
		"number":
			return node.value
		"binary":
			return eval_binary(node)
		"identifier":
			return get_variable(node.name)
		"bool":
			return node.value
		"array_access":
			return get_array_value(node)
		"string":
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
	var env = current_env()

	while env != null:
		var scopes = env["scope_stack"]

		for i in range(scopes.size() - 1, -1, -1):
			if name in scopes[i]:
				return scopes[i][name]["value"]

		env = env["parent"]  # 🔥 sobe na cadeia

	push_error("Variável não definida: " + str(name))
	return null

func set_variable(name, value):
	var env = current_env()

	while env != null:
		var scopes = env["scope_stack"]

		for i in range(scopes.size() - 1, -1, -1):
			if name in scopes[i]:
				var var_data = scopes[i][name]
				var_data["value"] = coerce_value(value, var_data["type"])
				return

		env = env["parent"]

	push_error("variável não declarada: " + name)

func process_assign(frame):
	match frame.index:
		0:
			push_frame("expression", frame.node.value)
			frame.index = 1
			return

		1:
			var target = frame.node.node
			if target.type == "identifier":
				set_variable(target.name, frame.state["value"])
			elif target.type == "array_access":
				var arr_wrapper = get_variable_wrapper(target.array.name)
				var arr = arr_wrapper["value"]

				var indexes = []
				for idx_node in target.indexes:
					indexes.append(eval(idx_node))

				var offset = compute_offset(indexes, arr["dimensions"])

				arr["data"][offset] = coerce_value(
					frame.state["value"],
					arr["element_type"]
				)
			else:
				push_error("destino invalido")

			pop_frame()

func process_var_decl(frame):
	match frame.index:
		0:
			if frame.node.value != null:
				push_frame("expression", frame.node.value)
				frame.index = 1
				return
			else:
				frame.state["value"] = null
				frame.index = 1

		1:
			declare_variable(frame.node.name, frame.state["value"],frame.node.type_var)
			pop_frame()

func declare_variable(name,value,type):
	# 🔥 se for função, NÃO faz cast
	if typeof(value) == TYPE_DICTIONARY and value.get("type") == "function":
		current_scope()[name] = {
			"type": "function",
			"value": value
		}
		return
	current_scope()[name] = {
		"type": type,
		"value": coerce_value(value, type)
	}

func process_if(frame):
	match frame.index:
		0:
			push_frame("expression",frame.node.condicao)
			frame.index = 1
			return
		1:
			frame.state["cond"] = frame.state["value"]
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
			push_frame("expression",frame.node.condicao)
			frame.index = 1
			return
		1:
			frame.state["cond"] = frame.state["value"]
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

		if frame.type == "while" or frame.type == "for":
			return

	push_error("break usado fora de loop")

func handle_continue():
	while not execution_stack.is_empty():
		var frame = current_frame()

		if frame.type == "while" or frame.type == "for":
			if frame.type == "for":
				frame.index = 3
				return
			frame.index = 0
			return

		pop_frame()

	push_error("continue usado fora de loop")

func process_return(frame):
	match frame.index:
		0:
			if frame.node.value != null:
				push_frame("expression", frame.node.value)
				frame.index = 1
				return
			else:
				frame.state["value"] = null
				frame.index = 2

		1:
			#print("Return: ", frame.state["value"])
			return make_signal(SIGNAL_RETURN, frame.state["value"])

func handle_return(signal_):
	var return_value = signal_.value

	while not execution_stack.is_empty():
		var frame = current_frame()

		if frame.type == "function_call":
			frame.state["return_value"] = return_value
			frame.index = 3
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
			declare_variable(frame.node.name, fn_obj,frame.node.type_var)
			frame.index = 1

		1:
			pop_frame()

func process_function_call(frame):
	match frame.index:
		# 0 → pegar função e preparar args
		0:
			var fn_name = frame.node.name

			#built-in?
			if fn_name in builtins:
				frame.state["builtin"] = builtins[fn_name]
				frame.state["is_builtin"] = true
				
				frame.state["args"] = []
				frame.state["arg_index"] = 0
				
				frame.index = 1
				return

			#função normal
			var fn = get_variable(fn_name)
			if fn == null or fn.type != "function":
				push_error("nao é função: ", frame.node.name)
				return

			frame.state["fn"] = fn
			frame.state["args"] = []
			frame.state["arg_index"] = 0

			frame.index = 1

		# 1 → resolver argumentos (step-by-step)
		1:
			var args_nodes = frame.node.args
			var i = frame.state["arg_index"]

			if i >= args_nodes.size():
				frame.index = 2
				return

			# resolve argumento atual
			push_frame("expression", args_nodes[i])
			frame.index = 1.5
			return

		# 1.5 → pegar resultado do argumento
		1.5:
			frame.state["args"].append(frame.state["value"])
			frame.state.erase("value") # 🔥 ESSENCIAL
			frame.state["arg_index"] += 1
			frame.index = 1

		# 2 → executar função
		2:
			if frame.state.get("is_builtin"):
				var result = frame.state["builtin"].call(frame.state["args"])
				
				deliver_result_to_parent(result)
				pop_frame()
				return
			var fn = frame.state["fn"]
			var args = frame.state["args"]

			var new_frame = {
				"name": fn.name,
				"scope_stack": [],
				"parent": current_env()
			}

			call_stack.append(new_frame)
			push_scope()

			for i in range(fn.params.size()):
				var param_type = fn.params[i][0]
				var param_name = fn.params[i][1]

				var value = args[i] if i < args.size() else null

				new_frame["scope_stack"].back()[param_name] = {
					"type": param_type,
					"value": coerce_value(value, param_type)
				}

			push_frame("block", fn.body)
			frame.index = 3
			return

		# 3 → esperar return
		3:
			frame.index = 4


		# 4 → finalizar
		4:
			var result = frame.state.get("return_value")

			call_stack.pop_back()

			deliver_result_to_parent(result)

			# 🔥 limpar estado
			frame.state.erase("return_value")

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
	if node.type == "array_access":
		return has_function_call(node.indexes[0])
	if node.type == "binary":
		return has_function_call(node.left) or has_function_call(node.right)
	return false

func process_expression(frame):
	var node = frame.node
	#print(node.type)
	match node.type:
		
		"number":
			deliver_result_to_parent(node.value)
			pop_frame()
			return
		
		"string":
			deliver_result_to_parent(node.value)
			pop_frame()
			return
		
		"array_access":
			var value = get_array_value(node)
			deliver_result_to_parent(value)
			pop_frame()
			return
		"bool":
			deliver_result_to_parent(node.value)
			pop_frame()
			return

		"identifier":
			var value = get_variable(node.name)
			deliver_result_to_parent(value)
			pop_frame()
			return

		"function_call":
			match frame.index:
				0:
					push_frame("function_call",node)
					frame.index = 1
				1:
					deliver_result_to_parent(frame.state["value"])

					pop_frame()
		"binary":
			if node.op.type == Token.TiposToken.OP_AND:
				match frame.index:
					0:
						push_frame("expression", node.left)
						frame.index = 1
						return

					1:
						var left = frame.state["value"]

						if not left:
							deliver_result_to_parent(false)
							pop_frame()
							return

						push_frame("expression", node.right)
						frame.index = 2
						return

					2:
						var right = frame.state["value"]
						deliver_result_to_parent(right)
						pop_frame()
			if node.op.type == Token.TiposToken.OP_OR:
				match frame.index:
					0:
						push_frame("expression", node.left)
						frame.index = 1
						return

					1:
						var left = frame.state["value"]

						if left:
							deliver_result_to_parent(true)
							pop_frame()
							return

						push_frame("expression", node.right)
						frame.index = 2
						return

					2:
						var right = frame.state["value"]
						deliver_result_to_parent(right)
						pop_frame()
			match frame.index:
				0:
					push_frame("expression", node.left)
					frame.index = 1
					return

				1:
					frame.state["left"] = frame.state["value"]

					push_frame("expression", node.right)
					frame.index = 2
					return

				2:
					frame.state["right"] = frame.state["value"]

					var l = frame.state["left"]
					var r = frame.state["right"]
					#print("l: ",l,"r: ",r)
					frame.state["result"] = apply_op(node.op, l, r)

					deliver_result_to_parent(frame.state["result"])
					pop_frame()
		"unary":
			match frame.index:
				0:
					push_frame("expression", node.operando)
					frame.index = 1
					return

				1:
					var value = frame.state["value"]

					match node.op.type:

						Token.TiposToken.OP_MINUS:
							deliver_result_to_parent(-value)

						Token.TiposToken.OP_NOT:
							deliver_result_to_parent(not value)

						Token.TiposToken.OP_PLUS_PLUS:
							if node.operando.type != "identifier":
								push_error("++ precisa de variável")
								return

							var name = node.operando.name
							var new_val = get_variable(name) + 1
							set_variable(name, new_val)

							if node.prefix:
								deliver_result_to_parent(new_val)
							else:
								deliver_result_to_parent(new_val - 1)

						Token.TiposToken.OP_MINUS_MINUS:
							var name = node.operando.name
							var new_val = get_variable(name) - 1
							set_variable(name, new_val)

							if node.prefix:
								deliver_result_to_parent(new_val)
							else:
								deliver_result_to_parent(new_val + 1)

					pop_frame()

func apply_op(op,left,right):
	# coerção automática
	if typeof(left) == TYPE_FLOAT or typeof(right) == TYPE_FLOAT:
		left = float(left)
		right = float(right)
	match op.type:
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
	
	push_error("Operador desconhecido")
	return null
					
func process_for(frame):
	match frame.index:

		# 0 → init
		0:
			if frame.node.init != null:
				push_frame(frame.node.init.type, frame.node.init)
				frame.index = 1
				return
			frame.index = 1

		# 1 → condição
		1:
			if frame.node.condicao != null:
				push_frame("expression", frame.node.condicao)
				frame.index = 2
				return
			frame.state["cond"] = true
			frame.index = 2

		# 2 → decidir se entra no loop
		2:
			if frame.node.condicao != null:
				frame.state["cond"] = frame.state["value"]

			if frame.state["cond"]:
				push_frame("block", frame.node.body)
				frame.index = 3
			else:
				pop_frame()

		# 3 → incremento
		3:
			if frame.node.incremento != null:
				push_frame("expression", frame.node.incremento)
				frame.index = 4
				return
			frame.index = 4

		# 4 → volta pro loop
		4:
			frame.index = 1

func coerce_value(value, target_type):
	if target_type == "array_decl":
		return value
	match target_type:
		"int":
			return int(value)
		"float":
			return float(value)
		"string":
			return str(value)

	push_error("tipo desconhecido: " + target_type)
	return value

func process_global_block(frame):
	var statements = frame.node.statements

	match frame.index:
		0:
			frame.state["i"] = 0
			frame.index = 1

		1:
			if frame.state["i"] >= statements.size():
				pop_frame()
				return

			var stmt = statements[frame.state["i"]]
			frame.state["i"] += 1
			#print("stmt: ",stmt)
			push_frame(stmt.type, stmt)

func process_array_decl(frame):
	match frame.index:
		0:
			var dimensions = []

			for size_node in frame.node.sizes:
				dimensions.append(eval(size_node))

			var total_size = 1
			for d in dimensions:
				total_size *= d

			var data = []
			for i in range(total_size):
				data.append(0)

			var arr_value = {
				"element_type": frame.node.type,
				"dimensions": dimensions,
				"data": data
			}

			declare_variable(
				frame.node.name,
				arr_value,
				"array"
			)

			frame.index = 1

		1:
			pop_frame()

func get_array_value(node):
	var arr_wrapper = get_variable_wrapper(node.array.name)
	var arr = arr_wrapper["value"]

	var indexes = []
	for idx_node in node.indexes:
		indexes.append(eval(idx_node))

	if indexes.size() != arr["dimensions"].size():
		push_error("dimensão incorreta")

	var offset = compute_offset(indexes, arr["dimensions"])

	return arr["data"][offset]

func compute_offset(indexes, dimensions):
	var offset = 0
	var stride = 1

	for i in range(dimensions.size() - 1, -1, -1):
		offset += indexes[i] * stride
		stride *= dimensions[i]

	return offset

func get_variable_wrapper(name):
	var env = current_env()

	while env != null:
		var scopes = env["scope_stack"]

		for i in range(scopes.size() - 1, -1, -1):
			if name in scopes[i]:
				return scopes[i][name]

		env = env["parent"]

	push_error("Variável não definida: " + str(name))
	return null
