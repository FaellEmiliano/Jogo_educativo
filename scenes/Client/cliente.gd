extends Control

var challenge
var input_instance = null

const _DIALOG_SCREEN :PackedScene = preload("res://scenes/client/dialog_screen.tscn")

@export_category("Objects")
@export var _hud :CanvasLayer = null


func _ready() -> void:
	EventBus.connect("input_submitted", validate)
	EventBus.send_output.connect(validate)


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
	if challenge == null:
		push_error("Context null no cliente!")
		return

	var dialog = {}
	var inputs = challenge.values

	# Introdução
	dialog[0] = {
		"faceset": "res://assets/sprites/faceset1.png",
		"dialog": "Olá! Gostaria de fazer uma compra.",
		"title": "Cliente"
	}

	# Pedido
	dialog[1] = {
		"faceset": "res://assets/sprites/faceset1.png",
		"dialog": gerar_texto_pedido(inputs),
		"title": "Cliente"
	}

	# Estado 2 (troco)
	if challenge.type == "troco":
		dialog[2] = {
		"faceset": "res://assets/sprites/faceset1.png",
			"dialog": "Vou pagar com R$ " + formatar(challenge.order.payment) + ". Quanto devo receber de troco?",
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
		if challenge.type == "troco" and i == inputs.size() - 1:
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
	var input_screen = preload("res://scenes/shared/input_screen.tscn")
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

	if valores.size() != challenge.expected_output.size():
		correto = false
	else:
		for i in range(valores.size()):
			if abs(valores[i] - challenge.expected_output[i]) > 0.01:
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
	if challenge.type == "soma":
		dialog = {
			0: {
				"faceset": "res://assets/sprites/faceset.png",
				"dialog": "O total é R$ " + formatar(valores[0]) + ".",
				"title": "Você"
			},
			1: {
		"faceset": "res://assets/sprites/faceset1.png",
				"dialog": "Perfeito, muito obrigado!",
				"title": "Cliente"
			}
		}

	# Estado 2 → total + troco
	elif challenge.type == "troco":
		dialog = {
			0: {
				"faceset": "res://assets/sprites/faceset.png",
				"dialog": "O total é R$ " + formatar(valores[0]) + 
						  " e o troco é R$ " + formatar(valores[1]) + ".",
				"title": "Você"
			},
			1: {
		"faceset": "res://assets/sprites/faceset1.png",
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
			"faceset": "res://assets/sprites/faceset.png",
			"dialog": "O total é R$ " + str(valores),
			"title": "Você"
		},
		1: {
		"faceset": "res://assets/sprites/faceset1.png",
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
	EventBus.emit_signal("end_client", true)
	queue_free()
