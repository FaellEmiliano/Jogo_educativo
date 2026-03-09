extends Node

class_name Token
var type
var value
func _init(t,v) -> void:
	type = t
	value = v

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
	KW_BREAK,
	KW_CONTINUE,
	
	#operadores
	OP_GREATER,
	OP_MINOR,
	OP_PLUS,
	OP_PLUS_PLUS,
	OP_MINUS,
	OP_MINUS_MINUS,
	OP_STAR,
	OP_SLASH,
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
