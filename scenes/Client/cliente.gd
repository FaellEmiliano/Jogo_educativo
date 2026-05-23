extends Control

signal result_closed()

var challenge
var active_dialog = null

const _DIALOG_SCREEN :PackedScene = preload("res://scenes/client/dialog_screen.tscn")

@export_category("Objects")
@export var _hud :CanvasLayer = null


func _show_dialog(dialog) -> DialogScreen:
	if active_dialog and is_instance_valid(active_dialog):
		active_dialog.queue_free()
	var _new_dialog : DialogScreen = _DIALOG_SCREEN.instantiate()
	_new_dialog.data = dialog
	_new_dialog.auto_advance = true
	_hud.add_child(_new_dialog)
	active_dialog = _new_dialog
	return _new_dialog


func show_request_dialog(new_challenge) -> void:
	challenge = new_challenge
	if challenge == null or _hud == null:
		push_error("Context null no cliente!")
		return

	var dialog = {}
	var inputs = challenge.values

	dialog[0] = {
		"faceset": "res://assets/sprites/faceset1.png",
		"dialog": "Olá! Gostaria de fazer uma compra.",
		"title": "Cliente"
	}

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

	_show_dialog(dialog)


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


func show_result_dialog(correto: bool, valores: Array) -> void:
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

	var dialog_screen = _show_dialog(dialog)
	dialog_screen.end_dialog.connect(_on_result_dialog_closed)


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
	var dialog_screen = _show_dialog(dialog)
	dialog_screen.end_dialog.connect(_on_result_dialog_closed)


# =========================
# FORMATAR DINHEIRO
# =========================
func formatar(valor):
	return str("%.2f" % valor)


func _on_result_dialog_closed() -> void:
	active_dialog = null
	result_closed.emit()
	queue_free()
