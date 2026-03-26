extends CharacterBody2D
class_name Robo
var api_robot = {}

func _ready() -> void:
	Eventos.api_robot.connect(event_call)
	build_api()

func build_api():
	api_robot["mover"] = func(args): mover(args[0])

func event_call(command,args):
	api_robot[command].call(args)

func mover(dir):
	var direction
	match dir:
		"north":
			direction = Vector2.UP
		"south":
			direction = Vector2.DOWN
		"east":
			direction = Vector2.RIGHT
		"west":
			direction = Vector2.LEFT
	position += direction *32


func _init() -> void:
	pass


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		Eventos.emit_signal('conectar_terminal',self)
