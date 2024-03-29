extends RigidBody3D

@export var interact_name:String = "WEAPON"
@export var interact_type:String = "PICK UP"
@export var weapon_stats:WeaponStats
@export var weapon: PackedScene
@export var current_ammo: int
@export var reserve_ammo: int
@export var is_interactable:bool = true
@export var keep_orig_rotation:bool = false


# Called when the node enters the scene tree for the first time.
func interact(player):
	print_debug("interact")
	var right_hand = player.find_child("Right_hand")
	var left_hand = player.find_child("Left_hand")
	var head = player.find_child("Head")
	var hurtboxloc = player.find_child("MeleeHitboxLoc")
	
	if weapon:
		var new_weapon = weapon.instantiate()
		var weapon_node = new_weapon.find_child("weapon_node")
		var hurtbox = new_weapon.find_child("hurtbox")
		
		weapon_stats.player = player
		
		new_weapon.weapon_stats = weapon_stats
		
		head.add_child(new_weapon)
		new_weapon.player = player
		if hurtbox:
			new_weapon.remove_child(hurtbox)
			hurtboxloc.add_child(hurtbox)
			#the hurtbox follows the headbob. maybe need to fix this...
		if weapon_node:
			var orig_pos = new_weapon.global_rotation
			
			head.remove_child(new_weapon)
			right_hand.add_child(new_weapon)
			if keep_orig_rotation:
				new_weapon.global_rotation = orig_pos
			#weapon_node.global_transform = right_hand.global_transform
		
		queue_free()
