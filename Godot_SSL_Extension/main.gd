extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var test = GDExample.new()
	test.set_time_passed(10.0)
	print(test.get_time_passed())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
