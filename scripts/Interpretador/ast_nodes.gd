extends Node

class_name ASTNodes

class ProgramNode extends  ASTNodes:
	var statements
	
	func _init(s):
		statements = s
		
	func accept(visitor):
			return visitor.visit_program(self)

class BlockNode extends  ASTNodes:
	var statements
	
	func _init(s):
		statements = s
		
	func accept(visitor):
		return visitor.visit_block(self)

class VarDeclNode extends  ASTNodes:
	var type
	var value
	
	func _init(t,n,v):
		type = t
		name = n
		value = v
	func accept(visitor):
		return visitor.visit_var_decl(self)

class IfNode extends  ASTNodes:
	var condicao
	var if_branch
	var else_branch
	
	func _init(c,i,e):
		condicao = c
		if_branch = i
		else_branch = e
		
	func accept(visitor):
		return visitor.visit_if(self)

class WhileNode extends  ASTNodes:
	var condicao
	var body
	
	func _init(c,b):
		condicao = c
		body = b
		
	func accept(visitor):
		return visitor.visit_while(self)

class ForNode extends  ASTNodes:
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
	
	func _init(v):
		value = v
	
	func accept(visitor):
		return visitor.visit_return(self)

class FunctionDeclNode extends  ASTNodes:
	var params
	var body
	
	func _init(n,p,b):
		name = n
		params = p
		body = b
		
	func accept(visitor):
		return visitor.visit_function_decl(self)


class FunctionCallNode extends  ASTNodes:

	var args
	
	func _init(n,a):
		name = n
		args = a
	func accept(visitor):
		return visitor.visit_function_call(self)

class ExpressionStatementNode extends  ASTNodes:
	var expression
	
	func _init(e):
		expression = e
	func accept(visitor):
		return visitor.visit_expression_statement(self)

class NumberNode extends ASTNodes:
	var value
	
	func _init(v):
		value = v
	func accept(visitor):
		return visitor.visit_number(self)

class StringNode extends  ASTNodes:
	var value
	
	func _init(v):
		value = v
	func accept(visitor):
		return visitor.visit_string(self)

class AssignNode extends  ASTNodes:
	var node
	var value
	
	func _init(n,v):
		node = n
		value = v
	func accept(visitor):
		return visitor.visit_assign(self)

class IdentifierNode extends  ASTNodes:
	func _init(n):
		name = n
	func accept(visitor):
		return visitor.visit_identifier(self)

class BreakNode extends  ASTNodes:
	pass

class ContinueNode extends  ASTNodes:
	pass

class UnaryOpNode extends  ASTNodes:
	var op
	var operando
	
	func _init(o,expr):
		op = o
		operando = expr

class BinaryOpNode extends  ASTNodes:
	var left
	var op
	var right
	
	func _init(l,o,r):
		left = l
		op = o
		right = r
		
	func accept(visitor):
		return visitor.visit_binary(self)
