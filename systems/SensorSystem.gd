extends Node

var sensors = {}

func set_sensor(name,value):
	sensors[name] = value
	print("setado: ",sensors[name])

func get_sensor(name):
	print(sensors)
	print(name)
	print("encontrado: ",sensors.get(name,false))
	return sensors.get(name,false)
