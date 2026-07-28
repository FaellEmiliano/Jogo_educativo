extends Node

class_name Token
var type
var value
var linha
var coluna
func _init(t="",v="",l := 0, c := 0) -> void:
	type = t
	value = v
	linha = l
	coluna = c

enum TiposToken{
	NUMBER,
	IDENTIFIER,
	STRING,
	
	#keywords
	KW_IF,
	KW_ELSE,
	KW_WHILE,
	KW_FOR,
	KW_FUNCTION,
	KW_RETURN,
	KW_INT,
	KW_FLOAT,
	KW_TRUE,
	KW_FALSE,
	KW_BREAK,
	KW_CONTINUE,
	
	#operadores
	OP_GREATER,
	OP_MINOR,
	OP_PLUS,
	OP_PLUS_PLUS,
	OP_PLUS_EQUAL,
	OP_MINUS,
	OP_MINUS_MINUS,
	OP_MINUS_EQUAL,
	OP_STAR,
	OP_STAR_EQUAL,
	OP_SLASH,
	OP_SLASH_EQUAL,
	OP_EQUAL,
	OP_EQUAL_EQUAL,
	OP_GREATER_EQUAL,
	OP_MINOR_EQUAL,
	OP_NOT_EQUAL,
	OP_NOT,
	OP_AND,
	OP_OR,
	OP_MOD,
	
	#delimitadores
	LPAREN,
	RPAREN,
	LBRACE,
	RBRACE,
	SEMICOLON,
	COMMA,
	LBRACKET,
	RBRACKET,
	DOT,
	COLON,
	
	
	EOF
}
