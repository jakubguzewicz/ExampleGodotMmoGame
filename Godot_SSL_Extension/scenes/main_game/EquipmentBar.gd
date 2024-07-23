extends HBoxContainer
@onready var characters = %Characters

var selected_item := 0

func _ready():
	for panel_container in get_children():
		var new_stylebox:StyleBoxTexture = panel_container.get_node("ItemSprite").get_theme_stylebox("panel").duplicate()
		panel_container.get_node("ItemSprite").add_theme_stylebox_override("panel", new_stylebox)
		var new_background:StyleBoxFlat = panel_container.get_node("Background").get_theme_stylebox("panel").duplicate()
		panel_container.get_node("Background").add_theme_stylebox_override("panel", new_background)

func refresh_equipment_bar(equipment_array:Array, new_selected_item:int):
	var panels = get_children()
	
	# Set correct textures for weapons
	for index in equipment_array.size():
		panels[index].get_node("ItemSprite").get_theme_stylebox("panel").texture = equipment_array[index].get_node("Weapon").texture
		
	# Add selected weapon border
	panels[selected_item].get_node("Background").get_theme_stylebox("panel").bg_color.v = 0.3
	selected_item = new_selected_item
	panels[selected_item].get_node("Background").get_theme_stylebox("panel").bg_color.v = 0.6
	
