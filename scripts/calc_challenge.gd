extends Control
@onready var history: RichTextLabel = $VBoxContainer2/VBoxContainer/Bash/history
@onready var input: LineEdit = $VBoxContainer2/VBoxContainer/Bash/input
@onready var window: VBoxContainer = $VBoxContainer2/VBoxContainer/Window



var inputs = [arredondar(randf_range(10.0, 2000.0),2),arredondar(randf_range(10.0, 2000.0),2)]
var saida_esperada = [inputs[0] + inputs[1]]

func _ready() -> void:
	Eventos.send_output.connect(validate_code)
	print_linha("< entrada 1: %s"%inputs[0])
	print_linha("< entrada 2: %s"%inputs[1])
	window.id = 1
	input.grab_focus()


func _on_input_text_submitted(text: String) -> void:
	print_linha("> "+text)
	validate_manual(text)
	input.text = ""

func print_linha(text):
	history.append_text(text + "\n")

func validate_manual(text):
	if text == str(saida_esperada):
		print_linha("< Sucesso!!!")
	else:
		print_linha("< Entrada inválida: "+text)

func validate_code(id,args):
	if id == 1:
		if args == saida_esperada:
			print_linha("< Sucesso!!!")
		else:
			print_linha("< Entrada inválida: "+ str(args))

func arredondar(valor, casas):
	var fator = pow(10, casas)
	return round(valor * fator) / fator
