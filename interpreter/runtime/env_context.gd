extends Node
class_name EnvContext

var inputs = []
var expected = []
var id 

func _init(i,_id,e):
	inputs = i
	expected = e
	id = _id
