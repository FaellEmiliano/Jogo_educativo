extends VBoxContainer
@onready var rich_text_label: RichTextLabel = $ColorRect3/MarginContainer/VBoxContainer/DebugFrame/RichTextLabel
@onready var toggle_button: Button = $ColorRect2/Button

var aberto := false
var _posicao_fechado := Vector2.ZERO
var _posicao_aberto := Vector2.ZERO

func _ready() -> void:
	_posicao_fechado = position
	_posicao_aberto = _posicao_fechado - Vector2(0, 404)
	set_aberto(aberto)
	EventBus.send_debug.connect(updt_debug)

func set_aberto(value: bool) -> void:
	if aberto == value and position == ( _posicao_aberto if aberto else _posicao_fechado ):
		return

	aberto = value
	position = _posicao_aberto if aberto else _posicao_fechado
	if toggle_button != null:
		toggle_button.set_pressed_no_signal(aberto)

func is_aberto() -> bool:
	return aberto

func _on_button_toggled(toggled_on: bool) -> void:
	set_aberto(toggled_on)

func updt_debug(texto):
	rich_text_label.text = str(texto)
