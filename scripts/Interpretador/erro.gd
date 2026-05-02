extends Node
class_name ErroInterpretador


var mensagem
var linha
var coluna

func _init(msg, l, c):
	mensagem = msg
	linha = l
	coluna = c
