extends RefCounted
class_name DeliveryProgramValidator

const Config = preload("res://data/DeliveryConfig.gd")


static func analyze(program) -> Dictionary:
	var result := {
		"valid": false,
		"errors": [],
		"recursive_functions": [],
		"has_user_function": false,
		"has_loop": false,
		"has_get_deliveries": false,
		"has_declare_profit": false,
		"has_response_array": false
	}
	if program == null:
		result["errors"].append("Não consegui analisar o programa do Delivery.")
		return result

	var all_nodes := _flatten(program)
	var array_sizes := {}
	var declare_calls := []
	var functions := []
	var recursive_declarations := []
	var valid_recursive_functions := []

	for node in all_nodes:
		if node is ASTNodes.FunctionDeclNode:
			functions.append(node)
			if str(node.name) != "main":
				result["has_user_function"] = true
		elif node is ASTNodes.ForNode or node is ASTNodes.WhileNode:
			result["has_loop"] = true
		elif node is ASTNodes.ArrayDeclNode:
			array_sizes[str(node.name)] = _static_array_size(node)
		elif node is ASTNodes.FunctionCallNode:
			if str(node.name) == "get_deliveries":
				result["has_get_deliveries"] = true
			elif str(node.name) == "declare_profit":
				result["has_declare_profit"] = true
				declare_calls.append(node)

	for function_node in functions:
		var function_name := str(function_node.name)
		if function_name == "main":
			continue
		var body_nodes := _flatten(function_node.body)
		var has_self_call := false
		var has_if := false
		var has_case_base := false
		for body_node in body_nodes:
			if body_node is ASTNodes.FunctionCallNode and str(body_node.name) == function_name:
				has_self_call = true
			elif body_node is ASTNodes.IfNode:
				has_if = true
				if _branch_is_case_base(body_node.if_branch, function_name) or _branch_is_case_base(body_node.else_branch, function_name):
					has_case_base = true
		if has_self_call:
			recursive_declarations.append(function_name)
			result["recursive_function_has_if"] = bool(result.get("recursive_function_has_if", false)) or has_if
			result["recursive_function_has_case_base"] = bool(result.get("recursive_function_has_case_base", false)) or has_case_base
			if has_if and has_case_base:
				valid_recursive_functions.append(function_name)

	result["recursive_functions"] = valid_recursive_functions

	for call_node in declare_calls:
		if call_node.args.size() != 1:
			continue
		var argument = call_node.args[0]
		if argument is ASTNodes.IdentifierNode and int(array_sizes.get(str(argument.name), -1)) == Config.REPORT_SIZE:
			result["has_response_array"] = true
		elif argument is ASTNodes.ArrayLiteralNode and argument.elements.size() == Config.REPORT_SIZE:
			result["has_response_array"] = true

	if not result["has_user_function"]:
		result["errors"].append("O desafio do Delivery precisa de uma função criada por você.")
	if recursive_declarations.is_empty():
		result["errors"].append("Uma função do cálculo precisa chamar a si mesma.")
	else:
		if not bool(result.get("recursive_function_has_if", false)):
			result["errors"].append("A função recursiva precisa usar if para reconhecer o caso-base.")
		if not bool(result.get("recursive_function_has_case_base", false)):
			result["errors"].append("Não encontrei um caso-base que interrompa a recursão.")
	if not result["has_loop"]:
		result["errors"].append("Use for ou while para processar as três categorias.")
	if not result["has_get_deliveries"]:
		result["errors"].append("Use get_deliveries() para ler o relatório atual.")
	if not result["has_declare_profit"]:
		result["errors"].append("Use declare_profit() para enviar os lucros.")
	if not result["has_response_array"]:
		result["errors"].append("declare_profit() precisa receber um array com 3 posições.")

	result["valid"] = result["errors"].is_empty()
	return result


static func _static_array_size(node: ASTNodes.ArrayDeclNode) -> int:
	if node.sizes.size() != 1:
		return -1
	var size_node = node.sizes[0]
	if size_node is ASTNodes.NumberNode:
		return int(size_node.value)
	return -1


static func _branch_is_case_base(branch, function_name: String) -> bool:
	if branch == null:
		return false
	var branch_nodes := _flatten(branch)
	var has_return := false
	for node in branch_nodes:
		if node is ASTNodes.ReturnNode:
			has_return = true
		elif node is ASTNodes.FunctionCallNode and str(node.name) == function_name:
			return false
	return has_return


static func _flatten(root) -> Array:
	var result := []
	if root == null:
		return result
	var stack := [root]
	while not stack.is_empty():
		var node = stack.pop_back()
		if node == null:
			continue
		result.append(node)
		var children := _children(node)
		for child in children:
			if child != null:
				stack.append(child)
	return result


static func _children(node) -> Array:
	if node is ASTNodes.ProgramNode or node is ASTNodes.BlockNode:
		return node.statements
	if node is ASTNodes.VarDeclNode:
		return [node.value]
	if node is ASTNodes.ArrayDeclNode:
		return node.sizes
	if node is ASTNodes.ArrayAccessNode:
		return [node.array] + node.indexes
	if node is ASTNodes.ArrayLiteralNode:
		return node.elements
	if node is ASTNodes.IfNode:
		return [node.condicao, node.if_branch, node.else_branch]
	if node is ASTNodes.WhileNode:
		return [node.condicao, node.body]
	if node is ASTNodes.ForNode:
		return [node.init, node.condicao, node.incremento, node.body]
	if node is ASTNodes.ReturnNode:
		return [node.value]
	if node is ASTNodes.FunctionDeclNode:
		return [node.body]
	if node is ASTNodes.FunctionCallNode:
		return node.args
	if node is ASTNodes.ExpressionStatementNode:
		return [node.expression]
	if node is ASTNodes.AssignNode:
		return [node.node, node.value]
	if node is ASTNodes.UnaryOpNode:
		return [node.operando]
	if node is ASTNodes.BinaryOpNode:
		return [node.left, node.right]
	return []
