extends Label

func _ready():
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time_left:float = $Timer.wait_time - $Timer.time_left
	self.text = String.num(time_left, 2)
