#analisa os tokens, semantica e gramatica!
extends Node

class_name Parser

var interpreter
var tokens = []
var pos = 0
var token_atual
var debug_enabled := false
var debug_indent := 0
var debug_lines := []

func _init(listatoken = [""]):
	tokens = listatoken
	token_atual = tokens[0]

# ─── Debug helpers ─────────────────────────────────────────────────────────────

func dbg(msg):
	if not debug_enabled:
		return
	var indent = "  ".repeat(debug_indent)
	debug_lines.append(indent + msg)

func dbg_enter(rule):
	dbg("→ " + rule)
	debug_indent += 1

func dbg_exit(rule):
	debug_indent -= 1
	dbg("← " + rule)

func dbg_token():
	dbg("TOKEN " + nome_token(token_atual.type) + " (" + str(token_atual.value) + ")")

# ─── Utilitários ───────────────────────────────────────────────────────────────

func avancar():
	pos += 1
	if pos < tokens.size():
		token_atual = tokens[pos]
	else:
		token_atual = tokens[-1]

func is_eof() -> bool:
	return token_atual.type == Token.TiposToken.EOF

func nome_token(tipo):
	for key in Token.TiposToken:
		if Token.TiposToken[key] == tipo:
			return key
	return "DESCONHECIDO"

func consumir(tipo):
	if token_atual.type == tipo:
		avancar()
	else:
		interpreter.registrar_erro(
			"Faltou '%s' aqui. Encontrei '%s' no lugar." % [nome_token(tipo), nome_token(token_atual.type)],
			token_atual.linha,
			token_atual.coluna,
			ErroInterpretador.TipoErro.SINTATICO
		)
		sincronizar()

## Recuperação de erro: avança até um ponto seguro para continuar o parsing
func sincronizar():
	while not is_eof():
		if token_atual.type == Token.TiposToken.SEMICOLON:
			avancar()
			return
		if token_atual.type in [
			Token.TiposToken.RBRACE,
			Token.TiposToken.KW_IF,
			Token.TiposToken.KW_WHILE,
			Token.TiposToken.KW_FOR,
			Token.TiposToken.KW_INT,
			Token.TiposToken.KW_FLOAT,
			Token.TiposToken.KW_RETURN
		]:
			return
		avancar()

# ─── Expressões ────────────────────────────────────────────────────────────────

func factor():
	dbg_enter("factor")
	var token = token_atual

	if token.type == Token.TiposToken.NUMBER:
		consumir(Token.TiposToken.NUMBER)
		dbg_exit("factor")
		return ASTNodes.NumberNode.new(token.value)

	if token.type == Token.TiposToken.KW_TRUE:
		consumir(Token.TiposToken.KW_TRUE)
		dbg_exit("factor")
		return ASTNodes.BoolNode.new(true)

	if token.type == Token.TiposToken.KW_FALSE:
		consumir(Token.TiposToken.KW_FALSE)
		dbg_exit("factor")
		return ASTNodes.BoolNode.new(false)

	if token.type == Token.TiposToken.STRING:
		consumir(Token.TiposToken.STRING)
		dbg_exit("factor")
		return ASTNodes.StringNode.new(token.value)

	if token.type == Token.TiposToken.IDENTIFIER:
		consumir(Token.TiposToken.IDENTIFIER)

		if token_atual.type == Token.TiposToken.LPAREN:
			var node = parse_function_call(token.value)
			dbg_exit("factor")
			return node

		if token_atual.type == Token.TiposToken.LBRACKET:
			var indexes = []
			var _guard = 0
			while token_atual.type == Token.TiposToken.LBRACKET and _guard < 16:
				_guard += 1
				consumir(Token.TiposToken.LBRACKET)
				indexes.append(assignment())
				consumir(Token.TiposToken.RBRACKET)
			var array = ASTNodes.IdentifierNode.new(token.value)
			dbg_exit("factor")
			return ASTNodes.ArrayAccessNode.new(array, indexes)

		dbg_exit("factor")
		return ASTNodes.IdentifierNode.new(token.value)

	if token.type == Token.TiposToken.LPAREN:
		consumir(Token.TiposToken.LPAREN)
		var node = expr()
		consumir(Token.TiposToken.RPAREN)
		dbg_exit("factor")
		return node

	if token.type == Token.TiposToken.LBRACKET:
		var node = parse_array_literal()
		dbg_exit("factor")
		return node

	# Token inválido — registra erro e retorna nó nulo seguro
	interpreter.registrar_erro(
		"Essa parte da expressão não fechou: '%s' ('%s')." % [nome_token(token.type), str(token.value)],
		token.linha,
		token.coluna,
		ErroInterpretador.TipoErro.SINTATICO
	)
	avancar() # consome o token problemático para não travar
	dbg_exit("factor")
	return ASTNodes.NumberNode.new(0) # nó neutro para não crashar

func parse_array_literal():
	consumir(Token.TiposToken.LBRACKET)
	var elements = []

	if token_atual.type != Token.TiposToken.RBRACKET:
		elements.append(assignment())
		var _guard = 0
		while token_atual.type == Token.TiposToken.COMMA and _guard < 1024:
			_guard += 1
			consumir(Token.TiposToken.COMMA)
			if token_atual.type == Token.TiposToken.RBRACKET:
				break
			elements.append(assignment())

	consumir(Token.TiposToken.RBRACKET)
	return ASTNodes.ArrayLiteralNode.new(elements)

func unary():
	if token_atual.type in [
		Token.TiposToken.OP_MINUS,
		Token.TiposToken.OP_NOT,
		Token.TiposToken.OP_PLUS_PLUS,
		Token.TiposToken.OP_MINUS_MINUS
	]:
		var op = token_atual
		avancar()
		return ASTNodes.UnaryOpNode.new(op, unary(), true)

	var node = factor()

	var _guard = 0
	while token_atual.type in [Token.TiposToken.OP_PLUS_PLUS, Token.TiposToken.OP_MINUS_MINUS] and _guard < 64:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.UnaryOpNode.new(op, node, false)

	return node

func term():
	var node = unary()
	var _guard = 0
	while token_atual.type in [Token.TiposToken.OP_STAR, Token.TiposToken.OP_SLASH, Token.TiposToken.OP_MOD] and _guard < 1024:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node, op, unary())
	return node

func expr():
	dbg_enter("expr")
	var node = term()
	var _guard = 0
	while token_atual.type in [Token.TiposToken.OP_PLUS, Token.TiposToken.OP_MINUS] and _guard < 1024:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node, op, term())
	dbg_exit("expr")
	return node

func comparison():
	var node = expr()
	var _guard = 0
	while token_atual.type in [
		Token.TiposToken.OP_MINOR,
		Token.TiposToken.OP_GREATER,
		Token.TiposToken.OP_MINOR_EQUAL,
		Token.TiposToken.OP_GREATER_EQUAL
	] and _guard < 1024:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node, op, expr())
	return node

func equality():
	var node = comparison()
	var _guard = 0
	while token_atual.type in [Token.TiposToken.OP_EQUAL_EQUAL, Token.TiposToken.OP_NOT_EQUAL] and _guard < 1024:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node, op, comparison())
	return node

func logical_and():
	var node = equality()
	var _guard = 0
	while token_atual.type == Token.TiposToken.OP_AND and _guard < 1024:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node, op, equality())
	return node

func logical_or():
	var node = logical_and()
	var _guard = 0
	while token_atual.type == Token.TiposToken.OP_OR and _guard < 1024:
		_guard += 1
		var op = token_atual
		avancar()
		node = ASTNodes.BinaryOpNode.new(node, op, logical_and())
	return node

func assignment():
	var node = logical_or()
	if token_atual.type in [
		Token.TiposToken.OP_EQUAL,
		Token.TiposToken.OP_PLUS_EQUAL,
		Token.TiposToken.OP_MINUS_EQUAL,
		Token.TiposToken.OP_STAR_EQUAL,
		Token.TiposToken.OP_SLASH_EQUAL
	]:
		var op = token_atual
		avancar()
		var value = assignment()
		node = ASTNodes.AssignNode.new(node, value, op)
	return node

# ─── Statements ────────────────────────────────────────────────────────────────

func parse_expression_statement():
	var node = assignment()
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.ExpressionStatementNode.new(node)

func statement():
	# Proteção: EOF inesperado dentro de bloco
	if is_eof():
		interpreter.registrar_erro(
			"O código acabou antes do esperado. Talvez esteja faltando '}'.",
			token_atual.linha, token_atual.coluna,
			ErroInterpretador.TipoErro.SINTATICO
		)
		return ASTNodes.ExpressionStatementNode.new(ASTNodes.NumberNode.new(0))

	match token_atual.type:
		Token.TiposToken.KW_BREAK:    return parse_break()
		Token.TiposToken.KW_CONTINUE: return parse_continue()
		Token.TiposToken.KW_IF:       return parse_if()
		Token.TiposToken.KW_WHILE:    return parse_while()
		Token.TiposToken.KW_FOR:      return parse_for()
		Token.TiposToken.KW_INT, Token.TiposToken.KW_FLOAT:
			return parse_declaration()
		Token.TiposToken.KW_RETURN:   return parse_return()
		Token.TiposToken.LBRACE:      return parse_block()
		Token.TiposToken.RBRACE:
			# '}' inesperado — não consome, deixa parse_block fechar
			interpreter.registrar_erro(
				"Tem um '}' sobrando aqui.",
				token_atual.linha, token_atual.coluna,
				ErroInterpretador.TipoErro.SINTATICO
			)
			return ASTNodes.ExpressionStatementNode.new(ASTNodes.NumberNode.new(0))
		_:
			return parse_expression_statement()

func parse_declaration():
	var tipo = token_atual
	avancar()
	var nome = token_atual.value
	consumir(Token.TiposToken.IDENTIFIER)

	if token_atual.type == Token.TiposToken.LPAREN:
		return parse_function_declaration(tipo.value, nome)
	if token_atual.type == Token.TiposToken.LBRACKET:
		return parse_array_declaration(tipo.value, nome)
	return parse_variable_declaration(tipo.value, nome)

func parse_variable_declaration(tipo, nome):
	var value = null
	if token_atual.type == Token.TiposToken.OP_EQUAL:
		consumir(Token.TiposToken.OP_EQUAL)
		value = assignment()
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.VarDeclNode.new(tipo, nome, value)

func parse_array_declaration(tipo, nome):
	var sizes = []
	var _guard = 0
	while token_atual.type == Token.TiposToken.LBRACKET and _guard < 16:
		_guard += 1
		consumir(Token.TiposToken.LBRACKET)
		sizes.append(assignment())
		consumir(Token.TiposToken.RBRACKET)
	consumir(Token.TiposToken.SEMICOLON)
	return ASTNodes.ArrayDeclNode.new(tipo, nome, sizes)

func parse_function_declaration(_tipo, nome):
	consumir(Token.TiposToken.LPAREN)
	var params = []

	if token_atual.type != Token.TiposToken.RPAREN:
		var _guard = 0
		while not is_eof() and _guard < 64:
			_guard += 1
			var ptype = token_atual.value
			consumir(Token.TiposToken.KW_INT)
			var pname = token_atual.value
			consumir(Token.TiposToken.IDENTIFIER)
			params.append([ptype, pname])
			if token_atual.type != Token.TiposToken.COMMA:
				break
			consumir(Token.TiposToken.COMMA)

	consumir(Token.TiposToken.RPAREN)
	var body = parse_block()
	return ASTNodes.FunctionDeclNode.new(_tipo, nome, params, body)

func parse_function_call(nome):
	consumir(Token.TiposToken.LPAREN)
	var args = []

	if token_atual.type != Token.TiposToken.RPAREN:
		args.append(expr())
		var _guard = 0
		while token_atual.type == Token.TiposToken.COMMA and _guard < 64:
			_guard += 1
			consumir(Token.TiposToken.COMMA)
			args.append(expr())

	consumir(Token.TiposToken.RPAREN)
	return ASTNodes.FunctionCallNode.new(nome, args)

func parse_block():
	consumir(Token.TiposToken.LBRACE)
	var statements_local = []
	var _guard = 0
	var MAX_STMTS = 10000

	# CRÍTICO: sem proteção aqui, um '}' faltando trava a Godot
	while not is_eof() and token_atual.type != Token.TiposToken.RBRACE and _guard < MAX_STMTS:
		_guard += 1
		var stmt = statement()
		if stmt != null:
			statements_local.append(stmt)
		# Se um erro fatal foi registrado, para imediatamente
		if interpreter.tem_erros() and _guard > 1:
			break

	if is_eof() and token_atual.type != Token.TiposToken.RBRACE:
		interpreter.registrar_erro(
			"Esse bloco não fechou. Falta um '}'.",
			token_atual.linha, token_atual.coluna,
			ErroInterpretador.TipoErro.SINTATICO
		)
	else:
		consumir(Token.TiposToken.RBRACE)

	return ASTNodes.BlockNode.new(statements_local)

func parse_if():
	if not FeatureManager.has_feature(FeatureManager.FEATURE_IF):
		interpreter.registrar_erro(
			FeatureManager.locked_message(FeatureManager.FEATURE_IF),
			token_atual.linha,
			token_atual.coluna,
			ErroInterpretador.TipoErro.RUNTIME
		)
	consumir(Token.TiposToken.KW_IF)
	consumir(Token.TiposToken.LPAREN)
	var condicao = assignment()
	consumir(Token.TiposToken.RPAREN)
	var if_branch = statement()
	var else_branch = null
	if token_atual.type == Token.TiposToken.KW_ELSE:
		consumir(Token.TiposToken.KW_ELSE)
		else_branch = statement()
	return ASTNodes.IfNode.new(condicao, if_branch, else_branch)

func parse_while():
	consumir(Token.TiposToken.KW_WHILE)
	consumir(Token.TiposToken.LPAREN)
	var condicao = assignment()
	consumir(Token.TiposToken.RPAREN)
	var body = statement()
	return ASTNodes.WhileNode.new(condicao, body)

func parse_for():
	consumir(Token.TiposToken.KW_FOR)
	consumir(Token.TiposToken.LPAREN)

	var init = null
	if token_atual.type in [Token.TiposToken.KW_INT, Token.TiposToken.KW_FLOAT]:
		init = parse_declaration()
	elif token_atual.type != Token.TiposToken.SEMICOLON:
		init = assignment()
		consumir(Token.TiposToken.SEMICOLON)
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

func parse():
	debug_lines.clear()
	dbg_enter("parse")
	var statements = []
	var _guard = 0
	while not is_eof() and _guard < 100000:
		_guard += 1
		statements.append(statement())
		# Para imediatamente se erros forem encontrados durante o parse global
		if interpreter.tem_erros():
			break
	dbg_exit("parse")
	return ASTNodes.ProgramNode.new(statements)

func print_parser():
	print("\n".join(debug_lines))
