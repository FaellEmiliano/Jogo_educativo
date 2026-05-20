extends Node
class_name ErroInterpretador

enum TipoErro {
	LEXICO,
	SINTATICO,
	SEMANTICO,
	RUNTIME
}

var mensagem: String
var linha: int
var coluna: int
var tipo: TipoErro

func _init(msg: String, l: int, c: int, t: TipoErro = TipoErro.RUNTIME):
	mensagem = msg
	linha = l
	coluna = c
	tipo = t

func formatar() -> String:
	var prefixo = ""
	match tipo:
		TipoErro.LEXICO:     prefixo = "[Léxico]"
		TipoErro.SINTATICO:  prefixo = "[Sintático]"
		TipoErro.SEMANTICO:  prefixo = "[Semântico]"
		TipoErro.RUNTIME:    prefixo = "[Runtime]"
	if linha >= 0:
		return "%s Linha %d, Col %d: %s" % [prefixo, linha, coluna, mensagem]
	return "%s %s" % [prefixo, mensagem]
