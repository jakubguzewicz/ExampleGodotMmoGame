extends Node
@onready var line_edit:LineEdit = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	#var test = GDExample.new()
	#test.set_time_passed(10.0)
	#print(test.get_time_passed())

	var aaa := line_edit.text
	print(aaa)
	print(aaa.to_utf8_buffer())
	var test := GameMessagesParser.log_in_request(aaa, "1qaz@WSX")
	print(test)
	var test2 := GameMessagesParser.parse_from_byte_array(test)
	print(test2)
	var text:String = test2["username"]
	print(text.to_utf8_buffer())
	
	

	pass # Replace with function body.
