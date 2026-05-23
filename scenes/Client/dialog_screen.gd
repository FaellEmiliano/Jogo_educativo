extends Control
class_name DialogScreen

var _step :float = 0.05

var _id :int = 0
var data :Dictionary = {}
var auto_advance := false
var auto_advance_delay := 1.2
var _advancing := false

signal end_dialog()



@export_category("Objects")
@export var _name :Label = null
@export var _dialog :RichTextLabel = null
@export var _faceset :TextureRect = null

func _ready() -> void:
	_initialize_dialog()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and _dialog.visible_ratio < 1:
		_step = 0.01
		return
	_step = 0.05
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _initialize_dialog() -> void:
	_advancing = false
	_name.text = data[_id]["title"]
	_dialog.text = data[_id]["dialog"]
	_faceset.texture = load(data[_id]["faceset"])
	
	_dialog.visible_characters = 0
	while _dialog.visible_ratio < 1:
		await get_tree().create_timer(_step).timeout
		_dialog.visible_characters += 1
	if auto_advance:
		_auto_advance_after_delay()


func _auto_advance_after_delay() -> void:
	if _advancing:
		return
	_advancing = true
	await get_tree().create_timer(auto_advance_delay).timeout
	if is_inside_tree():
		_advance()


func _advance() -> void:
	if _dialog.visible_ratio < 1:
		_dialog.visible_ratio = 1
		return
	_id += 1
	if _id == data.size():
		emit_signal("end_dialog")
		queue_free()
		return
	_initialize_dialog()
