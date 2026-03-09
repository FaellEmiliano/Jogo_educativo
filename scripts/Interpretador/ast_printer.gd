extends Node

class_name ASTPrinter

func print_ast(node, indent := ""):
	
	if node == null:
		print(indent + "null")
		return
	
	if node is ASTNodes.ProgramNode:
		print(indent + "Program")

		for stmt in node.statements:
			print_ast(stmt, indent + "  ")
			
		return
	
	if node is ASTNodes.BreakNode:
		print(indent + "Break")
		return
	
	if node is ASTNodes.ContinueNode:
		print(indent + "Continue")
		return
	
	if node is ASTNodes.BlockNode:
		print(indent + "Block")

		for stmt in node.statements:
			print_ast(stmt, indent + "  ")

		return
	
	if node is ASTNodes.VarDeclNode:

		print(indent + "VarDecl")

		print(indent + "  type: " + str(node.type))
		print(indent + "  name: " + node.name)

		print(indent + "  value:")
		print_ast(node.value, indent + "    ")

		return
	
	if node is ASTNodes.IfNode:

		print(indent + "If")

		print(indent + "  condition:")
		print_ast(node.condicao, indent + "    ")

		print(indent + "  then:")
		print_ast(node.if_branch, indent + "    ")

		if node.else_branch != null:
			print(indent + "  else:")
			print_ast(node.else_branch, indent + "    ")

		return
	
	if node is ASTNodes.WhileNode:

		print(indent + "While")

		print(indent + "  condition:")
		print_ast(node.condicao, indent + "    ")

		print(indent + "  body:")
		print_ast(node.body, indent + "    ")

		return
	
	if node is ASTNodes.ForNode:

		print(indent + "For")

		print(indent + "  init:")
		print_ast(node.init, indent + "    ")

		print(indent + "  condition:")
		print_ast(node.condicao, indent + "    ")

		print(indent + "  increment:")
		print_ast(node.incremento, indent + "    ")

		print(indent + "  body:")
		print_ast(node.body, indent + "    ")

		return
		
	if node is ASTNodes.ReturnNode:

		print(indent + "Return")

		print_ast(node.value, indent + "  ")

		return
		
	if node is ASTNodes.FunctionCallNode:

		print(indent + "FunctionCall: " + node.name)

		for arg in node.args:
			print_ast(arg, indent + "  ")

		return
	
	if node is ASTNodes.UnaryOpNode:

		print(indent + "UnaryOp: " + str(node.op.value))
		print_ast(node.operando, indent + "  ")

		return
	
	if node is ASTNodes.AssignNode:

		print(indent + "Assignment")

		print(indent + "  node:")
		print_ast(node.node, indent + "    ")

		print(indent + "  value:")
		print_ast(node.value, indent + "    ")

		return
	
	if node is ASTNodes.StringNode:
		print(indent + "String: " + node.value)
		return
	
	if node is ASTNodes.FunctionDeclNode:

		print(indent + "FunctionDecl: " + node.name)

		print(indent + "  params:")
		for p in node.params:
			print(indent + "    " + str(p))

		print(indent + "  body:")
		print_ast(node.body, indent + "    ")

		return
	
	if node is ASTNodes.ExpressionStatementNode:

		print(indent + "ExpressionStatement")

		print_ast(node.expression, indent + "  ")

		return
	

	if node is ASTNodes.NumberNode:
		print(indent + "Number: " + str(node.value))
		return

	if node is ASTNodes.IdentifierNode:
		print(indent + "Identifier: " + node.name)
		return

	if node is ASTNodes.BinaryOpNode:
		print(indent + "BinaryOp: " + str(node.op.value))
		print(indent + "├─ left")
		print_ast(node.left, indent + "│  ")
		print(indent + "└─ right")
		print_ast(node.right, indent + "│   ")
		return

	print(indent + "Unknown node: " + str(node.get_class()))
