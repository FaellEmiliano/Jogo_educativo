extends Control

const _DIALOG_SCREEN :PackedScene = preload("res://CEnas/dialog_screen.tscn")
var _dialog_data :Dictionary = {
	0: {
		"faceset": "res://icon.svg",
		"dialog": "Eu quero fazer uma compra!",
		"title": "cliente"
	},
	1: {
		"faceset": "res://icon.svg",
		"dialog": "me vê 2 pacotes de arroz, R$5,00 cada!",
		"title": "cliente"
	},
	2: {
		"faceset": "res://icon.svg",
		"dialog": "Obrigado!",
		"title": "cliente"
	},
	3: {
		"faceset": "res://sprites/robo.png",
		"dialog": "Volte sempre!",
		"title": "Você"
	}
}

@export_category("Objects")
@export var _hud :CanvasLayer = null

func _ready() -> void:
	var _new_dialog : DialogScreen = _DIALOG_SCREEN.instantiate()
	_new_dialog.data = _dialog_data
	_hud.add_child(_new_dialog)
