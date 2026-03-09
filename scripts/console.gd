extends Window

var alvo: Robo

func _ready() -> void:
	visible = false
	Eventos.conectar_terminal.connect(conectar)
	
func conectar(robo):
	alvo = robo
	visible = true

func _on_fechar_pressed() -> void:
	get_window().hide()

func _on_minimizar_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().size.y = 37
	else:
		get_window().size.y = 252
