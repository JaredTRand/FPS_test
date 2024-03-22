extends RigidBody3D

@export var interact_name:String = "WEAPON"
@export var interact_type:String = "PICK UP"
@export var weapon: PackedScene
@export var current_ammo: int
@export var reserve_ammo: int
var is_interactable:bool = true


# Called when the node enters the scene tree for the first time.
func interact():
	print_debug("interact")
	var right_hand = get_tree().get_nodes_in_group("Player")[0].find_child("Right_hand")
	if weapon:
		right_hand.add_child(weapon.instantiate())
		queue_free()
