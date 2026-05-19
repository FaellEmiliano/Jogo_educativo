extends Control

var context
var input_instance = null

const _DIALOG_SCREEN :PackedScene = preload("res://CEnas/dialog_screen.tscn")

@export_category("Objects")
@export var _hud :CanvasLayer = null


func _ready() -> void:
	Eventos.connect("input_submitted", validate)
	Eventos.send_output.connect(validate)


func _dialog_first(dialog) -> void:
	var _new_dialog : DialogScreen = _DIALOG_SCREEN.instantiate()
	_new_dialog.data = dialog
	_hud.add_child(_new_dialog)
	_new_dialog.connect("end_dialog", await_response)


func _dialog_second(dialog) -> void:
	var _new_dialog : DialogScreen = _DIALOG_SCREEN.instantiate()
	_new_dialog.data = dialog
	_hud.add_child(_new_dialog)
	_new_dialog.connect("end_dialog", end)


# =========================
# DIÁLOGO PRINCIPAL
# =========================
func run_dialog():
	if context == null:
		push_error("Context null no cliente!")
		return

	var dialog = {}
	var inputs = context.inputs

	# Introdução
	dialog[0] = {
		"faceset": "res://sprites/faceset1.png",
		"dialog": "Olá! Gostaria de fazer uma compra.",
		"title": "Cliente"
	}

	# Pedido
	dialog[1] = {
		"faceset": "res://sprites/faceset1.png",
		"dialog": gerar_texto_pedido(inputs),
		"title": "Cliente"
	}

	# Estado 2 (troco)
	if context.id == 2:
		dialog[2] = {
		"faceset": "res://sprites/faceset1.png",
			"dialog": "Vou pagar com R$ " + formatar(inputs[2]) + ". Quanto devo receber de troco?",
			"title": "Cliente"
		}

	_dialog_first(dialog)


# =========================
# GERA TEXTO DO PEDIDO
# =========================
func gerar_texto_pedido(inputs):
	if inputs.size() < 2:
		return "Tenho um pedido."

	var texto = "Gostaria de comprar dois itens: "

	for i in range(inputs.size()):
		# ignora o último se for dinheiro (estado 2)
		if context.id == 2 and i == inputs.size() - 1:
			break

		texto += "R$ " + formatar(inputs[i])

		if i == inputs.size() - 2:
			texto += " e "
		elif i < inputs.size() - 2:
			texto += ", "

	texto += ". Qual o valor total?"

	return texto


# =========================
# INPUT DO JOGADOR
# =========================
func await_response():
	var input_screen = preload("res://CEnas/input_screen.tscn")
	input_instance = input_screen.instantiate()
	_hud.add_child(input_instance)


# =========================
# VALIDAÇÃO
# =========================
func validate(text):
	if input_instance and is_instance_valid(input_instance):
		input_instance.queue_free()

	# text já é array → converter pra float
	var valores = []
	for v in text:
		var num = str(v).strip_edges().replace(",", ".")
		valores.append(float(num))

	var correto = true

	if valores.size() != context.expected.size():
		correto = false
	else:
		for i in range(valores.size()):
			if abs(valores[i] - context.expected[i]) > 0.01:
				correto = false

	if correto:
		dialogo_acerto(valores)
	else:
		dialogo_erro(valores)


# =========================
# DIÁLOGO DE ACERTO
# =========================
func dialogo_acerto(valores):
	var dialog = {}

	# Estado 1 → só total
	if context.id == 1:
		dialog = {
			0: {
				"faceset": "res://sprites/robo.png",
				"dialog": "O total é R$ " + formatar(valores[0]) + ".",
				"title": "Você"
			},
			1: {
		"faceset": "res://sprites/faceset1.png",
				"dialog": "Perfeito, muito obrigado!",
				"title": "Cliente"
			}
		}

	# Estado 2 → total + troco
	elif context.id == 2:
		dialog = {
			0: {
				"faceset": "res://sprites/robo.png",
				"dialog": "O total é R$ " + formatar(valores[0]) + 
						  " e o troco é R$ " + formatar(valores[1]) + ".",
				"title": "Você"
			},
			1: {
		"faceset": "res://sprites/faceset1.png",
				"dialog": "Perfeito! Tudo certo com o troco, obrigado!",
				"title": "Cliente"
			}
		}

	_dialog_second(dialog)


# =========================
# DIÁLOGO DE ERRO
# =========================
func dialogo_erro(valores):
	var dialog = {
		0: {
			"faceset": "res://sprites/robo.png",
			"dialog": "O total é R$ " + str(valores),
			"title": "Você"
		},
		1: {
		"faceset": "res://sprites/faceset1.png",
			"dialog": "Hmm... acho que esse valor não está correto.",
			"title": "Cliente"
		}
	}
	_dialog_second(dialog)


# =========================
# FORMATAR DINHEIRO
# =========================
func formatar(valor):
	return str("%.2f" % valor)


# =========================
# FINALIZA CLIENTE
# =========================
func end():
	Eventos.emit_signal("end_client", true)
	queue_free()
