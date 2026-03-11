#analisa os tokens, semantica e gramatica!
extends Node

class_name Parser
var tokens = []
var pos = 0
var token_atual

func _init(listatoken= [""]):
	tokens = listatoken
	token_atual = tokens[0]

func avancar():
	pos += 1
	if pos < tokens.size():
		token_atual = tokens[pos]
	else:
		token_atual = tokens[-1]
#debug
func nome_token(tipo):
	for key in Token.TiposToken:
		if Token.TiposToken[key] == tipo:
			return key
	return "DESCONHECIDO"
#tira o token atual da lista de tokens e valida ele
func consumir(tipo):
	print("TOKEN:", nome_token(token_atual.type)," ", token_atual.value)

	if token_atual.type == tipo:
		avancar()
	else:
		push_error(
			"Esperado: " + nome_token(tipo) +
			" recebido: " + nome_token(token_atual.type)
		)

#primeiro nivel
func factor():

	var token = token_atual

	# número
	if token.type == Token.TiposToken.NUMBER:
		consumir(Token.TiposToken.NUMBER)
		return ASTNodes.NumberNode.new(token.value)
	#string
	if token.type == Token.TiposToken.STRING:
		consumir(Token.TiposToken.STRING)
		return ASTNodes.StringNode.new(token.value)
	
	# identificador ou chamada
	if token.type == Token.TiposToken.IDENTIFIER:

		consumir(Token.TiposToken.IDENTIFIER)

		if token_atual.type == Token.TiposToken.LPAREN:
			return parse_function_call(token.value)

		var node = ASTNodes.IdentifierNode.new(token.value)

		return node

	# (expr)
	if token.type == Token.TiposToken.LPAREN:
		consumir(Token.TiposToken.LPAREN)
		var node = expr()
		consumir(Token.TiposToken.RPAREN)
		return node

	push_error("factor inválido")
	return null

func unary():#i++ ++i i-- --i
	# caso "nao"
	var node = factor()
	
	# PREFIX
	if token_atual.type in [
		Token.TiposToken.OP_MINUS,
		Token.TiposToken.OP_NOT,
		Token.TiposToken.OP_PLUS_PLUS,
		Token.TiposToken.OP_MINUS_MINUS
	]:
		var op = token_atual
		avancar()
		return ASTNodes.UnaryOpNode.new(op, unary())

	# POSTFIX
	while token_atual.type in [
		Token.TiposToken.OP_PLUS_PLUS,
		Token.TiposToken.OP_MINUS_MINUS
	]:
		var op = token_atual
		avancar()
		node = ASTNodes.UnaryOpNode.new(op, node)

	return node


func term():#op de / * e %
	#caso nao
	var node = unary()
	while token_atual.type in [Token.TiposToken.OP_STAR,Token.TiposToken.OP_SLASH,Token.TiposToken.OP_MOD]:
		var op = token_atual
		avancar()
		
		node = ASTNodes.BinaryOpNode.new(node,op,unary())
	
	return node

func expr():# + e -
	
	var node = term()
	
	while token_atual.type in  [Token.TiposToken.OP_PLUS,Token.TiposToken.OP_MINUS]:
		var op = token_atual
		avancar()
		
		node = ASTNodes.BinaryOpNode.new(node,op,term())
	return node

func comparison():# >= > <= e <
	#caso nao
	var node = expr()

	while token_atual.type in [
		Token.TiposToken.OP_MINOR,
		Token.TiposToken.OP_GREATER,
		Token.TiposToken.OP_MINOR_EQUAL,
		Token.TiposToken.OP_GREATER_EQUAL
	]:
		var op = token_atual
		avancar()

		node = ASTNodes.BinaryOpNode.new(node, op, expr())

	return node

func equality():# != e ==
	var node = comparison()
	
	while token_atual.type in [Token.TiposToken.OP_EQUAL_EQUAL,Token.TiposToken.OP_NOT_EQUAL]:
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node,op,comparison())
		
	return node

func logical_and():#&&
	var node = equality()
	
	while token_atual.type == Token.TiposToken.OP_AND:
		var op = token_atual
		avancar()
		
		node = ASTNodes.BinaryOpNode.new(node,op,equality())
	
	return node

func logical_or():#||
	var node = logical_and()
	
	while token_atual.type == Token.TiposToken.OP_OR:
		var op = token_atual
		avancar()
		
		node = ASTNodes.BinaryOpNode.new(node,op,logical_and())
	return node

func assignment():# atribuicao de variaveis(i = 10)
	var node = logical_or()

	if token_atual.type == Token.TiposToken.OP_EQUAL:
		var _op = token_atual
		consumir(Token.TiposToken.OP_EQUAL)

		var value = assignment()

		node = ASTNodes.AssignNode.new(node, value)

	return node

func parse_expression_statement():#instrucao que é uma expressao
	var node = assignment()
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.ExpressionStatementNode.new(node)

func statement():#Separa os tipos de instrucao
	match token_atual.type:
		
		Token.TiposToken.KW_BREAK:
			return parse_break()

		Token.TiposToken.KW_CONTINUE:
			return parse_continue()
		
		Token.TiposToken.KW_IF:
			return parse_if()

		Token.TiposToken.KW_WHILE:
			return parse_while()

		Token.TiposToken.KW_FOR:
			return parse_for()

		Token.TiposToken.KW_INT,Token.TiposToken.KW_FLOAT:
			return parse_declaration()

		Token.TiposToken.KW_RETURN:
			return parse_return()

		Token.TiposToken.LBRACE:
			return parse_block()

		_:
			return parse_expression_statement()

func parse_declaration():#declaracao de variavel ou funcao

	var tipo = token_atual
	avancar()

	var nome = token_atual.value
	consumir(Token.TiposToken.IDENTIFIER)

	# função
	if token_atual.type == Token.TiposToken.LPAREN:
		return parse_function_declaration(tipo.value, nome)

	# variável
	return parse_variable_declaration(tipo.value, nome)

func parse_variable_declaration(tipo, nome):#declaracao de variavel
	var value = null
	if token_atual.type == Token.TiposToken.OP_EQUAL:
		consumir(Token.TiposToken.OP_EQUAL)
		value = assignment()
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.VarDeclNode.new(tipo, nome, value)


func parse_function_declaration(tipo, nome):#Declaracao de funcao

	consumir(Token.TiposToken.LPAREN)

	var params = []

	if token_atual.type != Token.TiposToken.RPAREN:

		while true:

			var ptype = tipo
			avancar()

			var pname = nome
			consumir(Token.TiposToken.IDENTIFIER)

			params.append([ptype, pname])

			if token_atual.type != Token.TiposToken.COMMA:
				break

			consumir(Token.TiposToken.COMMA)

	consumir(Token.TiposToken.RPAREN)

	var body = parse_block()

	return ASTNodes.FunctionDeclNode.new(name, params, body)

func parse_function_call(nome):#chamadas de funcao gerais (chamado em factor)
	consumir(Token.TiposToken.LPAREN)
	var args = []
	
	if token_atual.type != Token.TiposToken.RPAREN:
		args.append(expr())
		
		while token_atual.type == Token.TiposToken.COMMA:
			consumir(Token.TiposToken.COMMA)
			args.append(expr())
	
	consumir(Token.TiposToken.RPAREN)
	return ASTNodes.FunctionCallNode.new(nome, args)

func parse_block():#blocos de codigo {}
	consumir(Token.TiposToken.LBRACE)
	var statements_local = []
	
	while token_atual.type != Token.TiposToken.RBRACE:
		statements_local.append(statement())
	
	consumir(Token.TiposToken.RBRACE)
	
	return ASTNodes.BlockNode.new(statements_local)

#CONTROLE DE FLUXO (chamada em statements)

func parse_if():
	consumir(Token.TiposToken.KW_IF)
	consumir(Token.TiposToken.LPAREN)
	
	var condicao = assignment()
	
	consumir(Token.TiposToken.RPAREN)
	var if_branch = statement()
	
	var else_branch = null
	
	if token_atual.type == Token.TiposToken.KW_ELSE:
		consumir(Token.TiposToken.KW_ELSE)
		else_branch = statement()
	
	return ASTNodes.IfNode.new(condicao,if_branch,else_branch)

func parse_while():
	consumir(Token.TiposToken.KW_WHILE)
	
	consumir(Token.TiposToken.LPAREN)
	var condicao = comparison()
	consumir(Token.TiposToken.RPAREN)
	
	var body = statement()
	
	return ASTNodes.WhileNode.new(condicao,body)

func parse_for():
	consumir(Token.TiposToken.KW_FOR)
	consumir(Token.TiposToken.LPAREN)

	var init = null

	# declaração de variável
	if token_atual.type in [Token.TiposToken.KW_INT, Token.TiposToken.KW_FLOAT]:
		init = parse_declaration()

	# atribuicao
	elif token_atual.type != Token.TiposToken.SEMICOLON:
		init = assignment()
	
	else:
		consumir(Token.TiposToken.SEMICOLON)


	var condicao = null
	if token_atual.type != Token.TiposToken.SEMICOLON:
		condicao = comparison()

	consumir(Token.TiposToken.SEMICOLON)

	var incremento = null
	if token_atual.type != Token.TiposToken.RPAREN:
		incremento = assignment()

	consumir(Token.TiposToken.RPAREN)

	var body = statement()

	return ASTNodes.ForNode.new(init, condicao, incremento, body)

func parse_return():
	
	consumir(Token.TiposToken.KW_RETURN)
	
	var value = null
	if token_atual.type != Token.TiposToken.SEMICOLON:
		value = assignment()
	
	consumir(Token.TiposToken.SEMICOLON)
	
	return ASTNodes.ReturnNode.new(value)

func parse_break():
	consumir(Token.TiposToken.KW_BREAK)
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.BreakNode.new()

func parse_continue():
	consumir(Token.TiposToken.KW_CONTINUE)
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.ContinueNode.new()

func parse(): #Funcao principal
	var statements = []
	while token_atual.type != Token.TiposToken.EOF:
		statements.append(statement())
	
	return ASTNodes.ProgramNode.new(statements)

##perceba que TODAS as funcoes necessitam de ; no final da linha (por causa do consumir)
#COMO DEBUGAR:
#Repare na saida do codigo e aonde o fluxo de tokens trava, o fluxograma do 
#codigo tambem é impresso pelo print_ast
