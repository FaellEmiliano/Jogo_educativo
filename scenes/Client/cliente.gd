extends Control

signal result_closed()

var challenge
var active_dialog = null

const _DIALOG_SCREEN :PackedScene = preload("res://scenes/Client/dialog_screen.tscn")

@export_category("Objects")
@export var _hud :CanvasLayer = null

@onready var client_texture: TextureRect = $TextureRect

func _ready() -> void:
	if challenge != null and challenge.is_golden:
		client_texture.modulate = Color(1.0, 0.82, 0.12)

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

	if _tem_troco():
		dialog[dialog.size()] = {
		"faceset": "res://assets/sprites/faceset1.png",
			"dialog": "Vou pagar com R$ " + formatar(challenge.order.payment) + ". Envie o total da compra e o troco.",
			"title": "Cliente"
		}

	_show_dialog(dialog)


# =========================
# GERA TEXTO DO PEDIDO
# =========================
func gerar_texto_pedido(inputs):
	if inputs.size() < 2:
		return "Tenho um pedido."

	if challenge.requires_stock:
		var texto_estoque = gerar_texto_ingredientes(challenge.requested_items, inputs)
		if challenge.applies_discount:
			texto_estoque += "\nSe passar de R$ 50, aplique 10% de desconto."
		if _tem_troco():
			texto_estoque += "\nDepois leia o pagamento e calcule o troco."
		return texto_estoque

	if challenge.type == "compra_variavel":
		var partes = []
		for value in inputs:
			partes.append("R$ " + formatar(value))
		var texto_carrinho = "Comprei varios itens: " + ", ".join(partes) + ". Some tudo ate receber -1"
		if challenge.applies_discount:
			texto_carrinho += ". Se passar de R$ 50, aplique 10% de desconto"
		if _tem_troco():
			return texto_carrinho + ". Depois leia o valor do pagamento, calcule o troco e envie total e troco."
		return texto_carrinho + " e envie o valor final."

	var texto = "Gostaria de comprar dois itens: "

	for i in range(inputs.size()):
		texto += "R$ " + formatar(inputs[i])

		if i == inputs.size() - 2:
			texto += " e "
		elif i < inputs.size() - 2:
			texto += ", "

	if challenge.applies_discount:
		texto += ". Se passar de R$ 50, aplique 10% de desconto"
	if _tem_troco():
		texto += ". Depois leia o pagamento, calcule o troco e envie total e troco"
	else:
		texto += ". Qual o valor total?"

	return texto

func gerar_texto_ingredientes(items: Array, inputs: Array) -> String:
	var linhas = ["Quero comprar:"]
	for i in range(items.size()):
		var item = items[i]
		var price_index = i * 2
		var price = inputs[price_index] if price_index < inputs.size() else 0.0
		linhas.append("%dx %s - R$ %s cada" % [
			int(item.get("quantity", 0)),
			str(item.get("name", "")),
			formatar(price)
		])
	linhas.append("Calcule o total da compra.")
	return "\n".join(linhas)


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

	if not _tem_troco():
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

	else:
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
	var resposta = "nenhum valor"
	if valores.size() == 1:
		resposta = formatar(valores[0])
	elif valores.size() > 1:
		var partes = []
		for valor in valores:
			partes.append(formatar(valor))
		resposta = ", ".join(partes)

	var dialog = {
		0: {
			"faceset": "res://assets/sprites/faceset.png",
			"dialog": "Minha resposta foi: " + resposta + ".",
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

func _tem_troco() -> bool:
	return challenge != null and challenge.expected_output.size() > 1


func _on_result_dialog_closed() -> void:
	active_dialog = null
	result_closed.emit()
	queue_free()
