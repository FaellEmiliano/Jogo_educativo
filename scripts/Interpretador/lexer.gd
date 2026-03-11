#classifica todas as palavras no codigo
extends Node

class_name Lexer

var origem: String
var posicao := 0
var char_atual : String
var keywords = {}
var operadores = {}
var delimitadores = {}
var linha = 1
var coluna = 1

#pega o codigo e constroi as tabelas
func _init(codigo = "") -> void:
	origem = codigo
	char_atual = origem[0] if origem.length() > 0 else ""
	build_keywords()
	build_operadores()
	build_single_char()

func build_keywords():
	for name_kw in Token.TiposToken.keys():
		
		if name_kw.begins_with("KW_"):
			var palavra = name_kw.substr(3).to_lower()
			keywords[palavra] = Token.TiposToken[name_kw]

func build_operadores():

	operadores[">"] = Token.TiposToken.OP_GREATER
	operadores["<"] = Token.TiposToken.OP_MINOR
	operadores["+"] = Token.TiposToken.OP_PLUS
	operadores["++"] = Token.TiposToken.OP_PLUS_PLUS
	operadores["-"] = Token.TiposToken.OP_MINUS
	operadores["--"] = Token.TiposToken.OP_MINUS_MINUS
	operadores["*"] = Token.TiposToken.OP_STAR
	operadores["/"] = Token.TiposToken.OP_SLASH
	operadores["="] = Token.TiposToken.OP_EQUAL
	operadores["=="] = Token.TiposToken.OP_EQUAL_EQUAL
	operadores[">="] = Token.TiposToken.OP_GREATER_EQUAL
	operadores["<="] = Token.TiposToken.OP_MINOR_EQUAL
	operadores["!="] = Token.TiposToken.OP_NOT_EQUAL
	operadores["!"] = Token.TiposToken.OP_NOT
	operadores["&&"] = Token.TiposToken.OP_AND
	operadores["||"] = Token.TiposToken.OP_OR
	operadores["%"] = Token.TiposToken.OP_MOD
	

func build_single_char():

	delimitadores["("] = Token.TiposToken.LPAREN
	delimitadores[")"] = Token.TiposToken.RPAREN
	delimitadores["{"] = Token.TiposToken.LBRACE
	delimitadores["}"] = Token.TiposToken.RBRACE
	delimitadores[";"] = Token.TiposToken.SEMICOLON
	delimitadores[","] = Token.TiposToken.COMMA
	delimitadores["["] = Token.TiposToken.LBRACKET
	delimitadores["]"] = Token.TiposToken.RBRACKET
	delimitadores["."] = Token.TiposToken.DOT
	delimitadores[":"] = Token.TiposToken.COLON

#funcao pra avancar a letra
func avancar():
	if char_atual == "\n":
		linha += 1
		coluna = 0
	
	coluna += 1
	posicao += 1
	if posicao >= origem.length():
		char_atual = ""
	else:
		char_atual = origem[posicao]
#funcao pra espiar o proximo caracter
func peek():
	var next_pos = posicao + 1
	
	if next_pos >= origem.length():
		return ""
	
	return origem[next_pos]
#pula espacos
func espaco():
	while char_atual == " " or char_atual == "\n" or char_atual == "\t" or char_atual == "\r":
		avancar()
#detecta strings
func string():

	var resultado = ""

	avancar()

	while char_atual != "" and char_atual != "\"":

		if char_atual == "\\":
			avancar()

			match char_atual:
				"n":
					resultado += "\n"
				"t":
					resultado += "\t"
				"\"":
					resultado += "\""
				_:
					resultado += char_atual
		else:
			resultado += char_atual

		avancar()

	if char_atual == "":
		push_error("String não fechada")
		return Token.new(Token.TiposToken.STRING, resultado)

	avancar()

	return Token.new(Token.TiposToken.STRING, resultado)
#detecta numeros
func numero():
	var resultado = ""
	var decimal = false
	
	while char_atual.is_valid_int() or char_atual == ".":
		
		if char_atual == ".":
			if decimal:
				break
			decimal = true
			
		resultado += char_atual
		avancar()
		
	if decimal:
		return Token.new(Token.TiposToken.NUMBER, float(resultado))
		
	return Token.new(Token.TiposToken.NUMBER, int(resultado))

func comentario_linha():

	while char_atual != "" and char_atual != "\n":
		avancar()

func comentario_multilinha():

	while char_atual != "":

		if char_atual == "*" and peek() == "/":
			avancar()
			avancar()
			return

		avancar()

	push_error("Comentário multilinha não fechado")

func is_letter(c: String) -> bool:
	return c.is_valid_ascii_identifier() and not c.is_valid_int()
#pega identificadores(nomes de variaveis/funcoes)
func identifier():
	var resultado = ""

	while char_atual != "" and (char_atual.is_valid_ascii_identifier() or 
	char_atual.is_valid_int() or char_atual == "_"):
		resultado += char_atual
		avancar()
	#pesquisa no dict
	if resultado in keywords:
		return Token.new(keywords[resultado], resultado)

	return Token.new(Token.TiposToken.IDENTIFIER, resultado)
#funcao principal
func get_next_token():

	while char_atual != "":

		if char_atual == " " or char_atual == "\n" or char_atual == "\t" or char_atual == "\r":
			espaco()
			continue

		if char_atual.is_valid_int():
			return numero()

		if char_atual.is_valid_ascii_identifier() or char_atual == "_":
			return identifier()

		if char_atual == "\"":
			return string()
		
		if char_atual == "/" and peek() == "/":
			avancar()
			avancar()
			comentario_linha()
			continue
		
		if char_atual == "/" and peek() == "*":
			avancar()
			avancar()
			comentario_multilinha()
			continue
		
		#operador duplo
		var two = char_atual + peek()

		if two in operadores:
			var tipo = operadores[two]
			avancar()
			avancar()
			return Token.new(tipo, two)
			
		# operador simples
		if char_atual in operadores:
			var c = char_atual
			var tipo = operadores[c]
			avancar()
			return Token.new(tipo, c)
			
		# delimitadores
		if char_atual in delimitadores:
			var c = char_atual
			var tipo = delimitadores[c]
			avancar()
			return Token.new(tipo, c)

		push_error("Caractere inválido: " + char_atual)
		avancar()
	return Token.new(Token.TiposToken.EOF, "")

func tokenize():
	
	var tokens = []
	var token = get_next_token()
	
	while token.type != Token.TiposToken.EOF:
		tokens.append(token)
		token = get_next_token()
	
	tokens.append(token)
	
	return tokens
