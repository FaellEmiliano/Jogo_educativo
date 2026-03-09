extends Node

class_name ASTNodes

class ProgramNode:
	var statements
	
	func _init(s):
		statements = s

class BlockNode:
	var statements
	
	func _init(s):
		statements = s

class VarDeclNode:
	var type
	var name
	var value
	
	func _init(t,n,v):
		type = t
		name = n
		value = v

class IfNode:
	var condicao
	var if_branch
	var else_branch
	
	func _init(c,i,e):
		condicao = c
		if_branch = i
		else_branch = e

class WhileNode:
	var condicao
	var body
	
	func _init(c,b):
		condicao = c
		body = b

class ForNode:
	var init
	var condicao
	var incremento
	var body
	
	func _init(i,c,inc,b):
		init = i
		condicao = c
		incremento = inc
		body = b

class ReturnNode:
	var value
	
	func _init(v):
		value = v

class FunctionDeclNode:
	var name
	var params
	var body
	
	func _init(n,p,b):
		name = n
		params = p
		body = b

class FunctionCallNode:
	var name
	var args
	
	func _init(n,a):
		name = n
		args = a

class ExpressionStatementNode:
	var expression
	
	func _init(e):
		expression = e

class NumberNode:
	var value
	
	func _init(v):
		value = v

class StringNode:
	var value
	
	func _init(v):
		value = v

class AssignNode:
	var node
	var value
	
	func _init(n,v):
		node = n
		value = v

class IdentifierNode:
	var name
	
	func _init(n):
		name = n

class BreakNode:
	pass

class ContinueNode:
	pass

class UnaryOpNode:
	var op
	var operando
	
	func _init(o,expr):
		op = o
		operando = expr

class BinaryOpNode:
	var left
	var op
	var right
	
	func _init(l,o,r):
		left = l
		op = o
		right = r
