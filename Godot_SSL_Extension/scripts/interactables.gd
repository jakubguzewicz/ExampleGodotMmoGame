extends Node


# TODO
# Remove after testing
const AXE = preload("res://assets/scenes/weapons/axe.tscn")
const WEAPON_PICKUP = preload("res://assets/scenes/interactables/weapon_pickup.tscn")
func _ready():
	var test_axe_pickup:WeaponPickup = WEAPON_PICKUP.instantiate()
	var axe:Weapon = AXE.instantiate()
	add_child(test_axe_pickup)
	test_axe_pickup.remove_child(test_axe_pickup.weapon)
	test_axe_pickup.add_child(axe)
	test_axe_pickup.weapon = axe


func interact(character:CharacterBody2D):
	var interactable = character.selected_interactable
	if is_instance_valid(interactable) and interactable is WeaponPickup:
		character.pickup_weapon(interactable)
		interactable.queue_free()
	else:
		pass
	
	
func find_closest(character:CharacterBody2D) -> Dictionary:
	var interactables = get_children()
	var closest_interactable:Node2D
	var closest_distance := 1.79769e308
	
	for interactable:Interactable in interactables:
		var distance = interactable.global_position.distance_to(character.global_position)
		if interactable.global_position.distance_to(character.global_position) < closest_distance:
			closest_interactable = interactable
			closest_distance = distance
		
	return {"interactable":closest_interactable, "distance":closest_distance}
	
func add_interactable(item, pickup_transform:=Transform2D()):
	if item is Weapon:
		var new_pickup := WEAPON_PICKUP.instantiate()
		add_child(new_pickup)
		new_pickup.transform = pickup_transform
		new_pickup.remove_child(new_pickup.weapon)
		new_pickup.add_child.call_deferred(item)
		new_pickup.weapon = item
	else:
		printerr("Tried to add new non-interactable item")
	
