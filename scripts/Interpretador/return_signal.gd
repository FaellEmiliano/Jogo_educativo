extends Node

class_name ControlSignal

class ReturnSignal extends ControlSignal:
	var value

	func _init(v) -> void:
		value = v

class BreakSignal extends ControlSignal:
	pass

class ContinueSignal extends ControlSignal:
	pass
