extends Node

var sensors = {}

func set_sensor(name,value):
	sensors[name] = value

func get_sensor(name):
	return sensors.get(name,false)
