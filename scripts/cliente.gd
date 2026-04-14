extends Control

var context

const _DIALOG_SCREEN :PackedScene = preload("res://CEnas/dialog_screen.tscn")
var _dialog_data :Dictionary = {
	0: {
		"faceset": "res://icon.svg",
		"dialog": "Eu quero fazer uma compra!",
		"title": "cliente"
	},
	1: {
		"faceset": "res://icon.svg",
		"dialog": "Eu tenho dois pedidos, um de ",
		"title": "cliente"
	}
}

@export_category("Objects")
@export var _hud :CanvasLayer = null

func _dialog(dialog) -> void:
	var _new_dialog : DialogScreen = _DIALOG_SCREEN.instantiate()
	_new_dialog.data = dialog
	_hud.add_child(_new_dialog)

func run_dialog():
	var dialog = {
	0: {
		"faceset": "res://icon.svg",
		"dialog": "Eu quero fazer uma compra!",
		"title": "cliente"
	},
	1: {
		"faceset": "res://icon.svg",
		"dialog": "Eu tenho dois pedidos, um de "+ str(context.inputs[0])+" e um de "+ str(context.inputs[1]) 
		+ "\n Qual o total?",
		"title": "cliente"
	}
	}
	_dialog(dialog)
func check_response():
	pass
