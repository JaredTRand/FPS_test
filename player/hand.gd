extends Node3D
@onready var original_pos:Vector3 = transform.origin
@onready var original_rot:Quaternion = self.quaternion

var current_pos:Vector3
var current_rot:Quaternion

var target_pos:Vector3
var target_rot:Quaternion

var is_lerping:bool = false
@export var lerp_speed = 20 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_pos = transform.origin
	current_rot = self.quaternion
	
	if is_lerping:
		do_lerp(delta)

func new_lerp_to(new_position:Vector3 = original_pos, new_rotation:Quaternion = original_rot):
	is_lerping = true
	target_pos = new_position
	target_rot = new_rotation

func do_lerp(delta):
	var at_pos = current_pos == target_pos
	var at_rot = current_rot == target_rot
	
	if not at_pos:
		transform.origin = transform.origin.slerp(target_pos, lerp_speed*delta)
	if not at_rot:
		self.quaternion = self.quaternion.slerp(target_rot, lerp_speed * delta)
		
	if at_pos and at_rot:
		is_lerping = false
