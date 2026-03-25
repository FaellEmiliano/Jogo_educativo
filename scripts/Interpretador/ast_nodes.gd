extends Node

class_name ASTNodes

class ProgramNode extends  ASTNodes:
	var statements
	
	func _init(s):
		statements = s

class BlockNode extends  ASTNodes:
	var statements
	var type = "block"
	
	func _init(s):
		statements = s

class VarDeclNode extends  ASTNodes:
	var type = "var_decl"
	var type_var
	var value
	
	func _init(t,n,v):
		type_var = t
		name = n
		value = v
		
class ArrayDeclNode extends ASTNodes:
	var type = "array_decl"
	var type_var
	var sizes
	
	func _init(t,n,s):
		type_var = t
		name = n
		sizes = s
	

class ArrayAccessNode extends ASTNodes:
	var type = "array_access"
	var array
	var indexes
	
	func _init(a,i):
		array = a
		indexes = i
	
class IfNode extends  ASTNodes:
	var type = "if"
	var condicao
	var if_branch
	var else_branch
	
	func _init(c,i,e):
		condicao = c
		if_branch = i
		else_branch = e
		
class WhileNode extends  ASTNodes:
	var type = "while"
	var condicao
	var body
	
	func _init(c,b):
		condicao = c
		body = b
		

class ForNode extends  ASTNodes:
	var type = "for"
	var init
	var condicao
	var incremento
	var body
	
	func _init(i,c,inc,b):
		init = i
		condicao = c
		incremento = inc
		body = b

class ReturnNode extends  ASTNodes:
	var value
	var type = "return"
	
	func _init(v):
		value = v

class FunctionDeclNode extends  ASTNodes:
	var type_var
	var params
	var body
	var type = "function_decl"
	
	func _init(t,n,p,b):
		type_var = t
		name = n
		params = p
		body = b

class FunctionCallNode extends  ASTNodes:
	var type = "function_call"
	var args
	
	func _init(n,a):
		name = n
		args = a

class ExpressionStatementNode extends  ASTNodes:
	var expression
	var type = "expression_statement"
	
	func _init(e):
		expression = e

class NumberNode extends ASTNodes:
	var value
	var type = "number"

	func _init(v):
		value = v

class StringNode extends  ASTNodes:
	var value
	
	func _init(v):
		value = v

class AssignNode extends  ASTNodes:
	var node
	var value
	var type = "assign"
	
	func _init(n,v):
		node = n
		value = v

class IdentifierNode extends  ASTNodes:
	var type = "identifier"
	func _init(n):
		name = n

class BreakNode extends  ASTNodes:
	var type = 'break'

class ContinueNode extends  ASTNodes:
	var type = "continue"

class UnaryOpNode extends  ASTNodes:
	var op
	var operando
	var prefix
	var type = "unary"
	
	func _init(o,expr,p):
		op = o
		operando = expr
		prefix = p

class BinaryOpNode extends  ASTNodes:
	var left
	var op
	var right
	var type = "binary"
	
	func _init(l,o,r):
		left = l
		op = o
		right = r

class BoolNode extends ASTNodes:
	var value
	var type = "bool"
	func _init(v) -> void:
		if v == "false":
			value = false
		elif v == "true":
			value = true
		else:
			value = null
