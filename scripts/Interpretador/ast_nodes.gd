extends Node

class_name ASTNodes

class ProgramNode extends  ASTNodes:
	var statements
	
	func _init(s):
		statements = s
		
	func accept_exec(visitor):
			return visitor.exec_program(self)

class BlockNode extends  ASTNodes:
	var statements
	
	func _init(s):
		statements = s
		
	func accept_exec(visitor):
		return visitor.exec_block(self)

class VarDeclNode extends  ASTNodes:
	var type
	var value
	
	func _init(t,n,v):
		type = t
		name = n
		value = v
	func accept_exec(visitor):
		return visitor.exec_var_decl(self)

class ArrayDeclNode extends ASTNodes:
	var type
	var sizes
	
	func _init(t,n,s):
		type = t
		name = n
		sizes = s
	
	func accept_exec(visitor):
		return visitor.exec_array_decl(self)

class ArrayAccessNode extends ASTNodes:
	var array
	var indexes
	
	func _init(a,i):
		array = a
		indexes = i
	
	func accept_eval(visitor):
		return visitor.eval_array_acess(self)

class IfNode extends  ASTNodes:
	var condicao
	var if_branch
	var else_branch
	
	func _init(c,i,e):
		condicao = c
		if_branch = i
		else_branch = e
		
	func accept_exec(visitor):
		return visitor.exec_if(self)

class WhileNode extends  ASTNodes:
	var condicao
	var body
	
	func _init(c,b):
		condicao = c
		body = b
		
	func accept_exec(visitor):
		return visitor.exec_while(self)

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
	func accept_exec(visitor):
		return visitor.exec_for(self)

class ReturnNode extends  ASTNodes:
	var value
	
	func _init(v):
		value = v
	
	func accept_exec(visitor):
		return visitor.exec_return(self)

class FunctionDeclNode extends  ASTNodes:
	var params
	var body
	
	func _init(n,p,b):
		name = n
		params = p
		body = b
		
	func accept_exec(visitor):
		return visitor.exec_function_decl(self)


class FunctionCallNode extends  ASTNodes:

	var args
	
	func _init(n,a):
		name = n
		args = a
	func accept_eval(visitor):
		return visitor.eval_function_call(self)

class ExpressionStatementNode extends  ASTNodes:
	var expression
	
	func _init(e):
		expression = e
	func accept_exec(visitor):
		return visitor.exec_expression_statement(self)

class NumberNode extends ASTNodes:
	var value
	
	func _init(v):
		value = v
	func accept_eval(visitor):
		return visitor.eval_number(self)

class StringNode extends  ASTNodes:
	var value
	
	func _init(v):
		value = v
	func accept_eval(visitor):
		return visitor.eval_string(self)

class AssignNode extends  ASTNodes:
	var node
	var value
	
	func _init(n,v):
		node = n
		value = v
	func accept_eval(visitor):
		return visitor.eval_assign(self)

class IdentifierNode extends  ASTNodes:
	func _init(n):
		name = n
	func accept_eval(visitor):
		return visitor.eval_identifier(self)

class BreakNode extends  ASTNodes:
	func accept_exec(visitor):
		return visitor.exec_break(self)

class ContinueNode extends  ASTNodes:
	func accept_exec(visitor):
		return visitor.exec_continue(self)

class UnaryOpNode extends  ASTNodes:
	var op
	var operando
	var prefix
	
	func _init(o,expr,p):
		op = o
		operando = expr
		prefix = p

	func accept_eval(visitor):
		return visitor.eval_unary(self)

class BinaryOpNode extends  ASTNodes:
	var left
	var op
	var right
	
	func _init(l,o,r):
		left = l
		op = o
		right = r
		
	func accept_eval(visitor):
		return visitor.eval_binary(self)

class BoolNode extends ASTNodes:
	var value
	func _init(v) -> void:
		if v == "false":
			value = false
		elif v == "true":
			value = true
		else:
			value = null
	func accept_eval(visitor):
		return visitor.eval_bool(self)
