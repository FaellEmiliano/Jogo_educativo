extends CharacterBody2D
class_name Robo
var api_robot = {}
@onready var mapa = $"../Mapa"

func _ready() -> void:
	Eventos.api_robot.connect(event_call)
	build_api()

func build_api():
	api_robot["mover"] = func(args): mover(args[0])
	api_robot["mine"] = func(args): mine(args[0])

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
	var current_cell = mapa.local_to_map(position)
	var target_cell = current_cell + Vector2i(direction)
	if mapa.get_cell_source_id(target_cell) == -1:
		print("nao eh bloco")
		return 
	position = mapa.map_to_local(target_cell)

func mine(dir):
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
	var current_cell = mapa.local_to_map(position)
	var target_cell = current_cell + Vector2i(direction)
	if mapa.get_cell_source_id(target_cell) == 1:
		print("eh minerio")
	else:
		print("nao eh minerio")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		Eventos.emit_signal('conectar_terminal',self)
