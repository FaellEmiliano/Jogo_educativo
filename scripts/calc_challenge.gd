extends Control
@onready var history: RichTextLabel = $Main/VBoxContainer2/Bash/history
@onready var input: LineEdit = $Main/VBoxContainer2/Bash/input
@onready var window: VBoxContainer = $Main/Window




var inputs
var saida_esperada


func _ready() -> void:
	Eventos.send_output.connect(validate_code)
	input.grab_focus()
	_init_game()

func _init_game():
	inputs = [arredondar(randf_range(10.0, 2000.0),2),arredondar(randf_range(10.0, 2000.0),2)]
	saida_esperada = [inputs[0] + inputs[1]]
	window.context = EnvContext.new(inputs,1,saida_esperada)
	print_linha("< entrada 1: %s"%inputs[0])
	print_linha("< entrada 2: %s"%inputs[1])
	
	

func _on_input_text_submitted(text: String) -> void:
	print_linha("> "+text)
	validate_manual(text)
	input.text = ""

func print_linha(text):
	history.append_text(text + "\n")
	history.scroll_to_line(history.get_line_count() - 1)

func validate_manual(text):
	if text == str(saida_esperada):
		print_linha("< Sucesso!!!")
	else:
		print_linha("< Entrada inválida: "+text)

func validate_code(id,args):
	print_linha("> "+str(args))
	if id == 1:
		if args == saida_esperada:
			print_linha("< Sucesso!!!")
		else:
			print_linha("< Entrada inválida: "+ str(args))
	window.running = false

func arredondar(valor, casas):
	var fator = pow(10, casas)
	return round(valor * fator) / fator
