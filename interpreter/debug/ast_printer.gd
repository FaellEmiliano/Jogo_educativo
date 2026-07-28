# SOMENTE PRA DEBUG
extends Node
class_name ASTPrinter


func print_ast(node):
	var text = ast_to_string(node)
	print(text)


func ast_to_string(node, indent := "", is_last := true) -> String:
	var out := ""

	var branch := "└─ " if is_last else "├─ "
	var next_indent := indent + ("   " if is_last else "│  ")

	if node == null:
		return indent + branch + "null\n"

	# ---------- LISTAS ----------
	if node is Array:
		for i in node.size():
			out += ast_to_string(node[i], indent, i == node.size()-1)
		return out


	# ---------- PROGRAM ----------
	if node is ASTNodes.ProgramNode:
		out += indent + branch + "Program\n"
		for i in node.statements.size():
			out += ast_to_string(node.statements[i], next_indent, i == node.statements.size()-1)
		return out


	# ---------- BLOCK ----------
	if node is ASTNodes.BlockNode:
		out += indent + branch + "Block\n"
		for i in node.statements.size():
			out += ast_to_string(node.statements[i], next_indent, i == node.statements.size()-1)
		return out


	# ---------- VAR DECL ----------
	if node is ASTNodes.VarDeclNode:
		out += indent + branch + "VarDecl (" + node.name + ":" + str(node.type_var) + ")\n"

		if node.value != null:
			out += ast_to_string(node.value, next_indent, true)

		return out


	# ---------- ARRAY DECL ----------
	if node is ASTNodes.ArrayDeclNode:
		out += indent + branch + "ArrayDecl (" + node.name + ":" + str(node.type) + ")\n"

		for i in node.sizes.size():
			out += ast_to_string(node.sizes[i], next_indent, i == node.sizes.size()-1)

		return out


	# ---------- ARRAY ACCESS ----------
	if node is ASTNodes.ArrayAccessNode:
		out += indent + branch + "ArrayAccess\n"

		out += ast_to_string(node.array, next_indent, false)

		for i in node.indexes.size():
			out += ast_to_string(node.indexes[i], next_indent, i == node.indexes.size()-1)

		return out

	if node is ASTNodes.ArrayLiteralNode:
		out += indent + branch + "ArrayLiteral\n"

		for i in node.elements.size():
			out += ast_to_string(node.elements[i], next_indent, i == node.elements.size()-1)

		return out


	# ---------- IF ----------
	if node is ASTNodes.IfNode:
		out += indent + branch + "If\n"

		out += ast_to_string(node.condicao, next_indent, false)
		out += ast_to_string(node.if_branch, next_indent, node.else_branch == null)

		if node.else_branch != null:
			out += ast_to_string(node.else_branch, next_indent, true)

		return out


	# ---------- WHILE ----------
	if node is ASTNodes.WhileNode:
		out += indent + branch + "While\n"

		out += ast_to_string(node.condicao, next_indent, false)
		out += ast_to_string(node.body, next_indent, true)

		return out


	# ---------- FOR ----------
	if node is ASTNodes.ForNode:
		out += indent + branch + "For\n"

		out += ast_to_string(node.init, next_indent, false)
		out += ast_to_string(node.condicao, next_indent, false)
		out += ast_to_string(node.incremento, next_indent, false)
		out += ast_to_string(node.body, next_indent, true)

		return out


	# ---------- FUNCTION DECL ----------
	if node is ASTNodes.FunctionDeclNode:
		out += indent + branch + "FunctionDecl " + node.name + "\n"

		for p in node.params:
			out += next_indent + "├─ param " + str(p) + "\n"

		out += ast_to_string(node.body, next_indent, true)

		return out


	# ---------- FUNCTION CALL ----------
	if node is ASTNodes.FunctionCallNode:
		out += indent + branch + "Call " + node.name + "\n"

		for i in node.args.size():
			out += ast_to_string(node.args[i], next_indent, i == node.args.size()-1)

		return out


	# ---------- ASSIGN ----------
	if node is ASTNodes.AssignNode:
		out += indent + branch + "Assign\n"

		out += ast_to_string(node.node, next_indent, false)
		out += ast_to_string(node.value, next_indent, true)

		return out


	# ---------- RETURN ----------
	if node is ASTNodes.ReturnNode:
		out += indent + branch + "Return\n"
		out += ast_to_string(node.value, next_indent, true)
		return out

	# ---------- EXPRESSION STATEMENT ----------
	if node is ASTNodes.ExpressionStatementNode:
		out += indent + branch + "ExpressionStatement\n"
		out += ast_to_string(node.expression, next_indent, true)
		return out

	# ---------- EXPRESSIONS ----------
	if node is ASTNodes.BinaryOpNode:
		out += indent + branch + "BinaryOp " + str(node.op.value) + "\n"

		out += ast_to_string(node.left, next_indent, false)
		out += ast_to_string(node.right, next_indent, true)

		return out


	if node is ASTNodes.UnaryOpNode:
		out += indent + branch + "UnaryOp " + str(node.op.value) + "\n"
		out += ast_to_string(node.operando, next_indent, true)
		return out


	# ---------- TERMINAIS ----------
	if node is ASTNodes.NumberNode:
		return indent + branch + "Number " + str(node.value) + "\n"

	if node is ASTNodes.StringNode:
		return indent + branch + "String \"" + node.value + "\"\n"

	if node is ASTNodes.IdentifierNode:
		return indent + branch + "Identifier " + node.name + "\n"

	if node is ASTNodes.BreakNode:
		return indent + branch + "Break\n"

	if node is ASTNodes.ContinueNode:
		return indent + branch + "Continue\n"

	return indent + branch + "Unknown " + str(node) + "\n"
