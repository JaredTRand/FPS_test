extends Node3D
@onready var original_pos:Vector3 = transform.origin
@onready var original_rot:Quaternion = self.quaternion

var current_pos:Vector3
var current_rot:Quaternion

var target_pos:Vector3
var target_rot:Quaternion

var is_lerping:bool = false
@export var lerp_speed = 20 
var default_lerp_speed
var current_point:String
var lerping_to_point:String
@export var lerp_points:Dictionary


func _ready():
	default_lerp_speed = lerp_speed
	lerp_points["original"] =  [original_pos, original_rot]
	current_point = "original"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_pos = transform.origin
	current_rot = self.quaternion
	
	if is_lerping:
		do_lerp(delta)

func new_lerp_to(new_position:Vector3, new_rotation:Quaternion, speed = default_lerp_speed):
	is_lerping = true
	lerp_speed = speed
	target_pos = new_position
	target_rot = new_rotation
	
func lerp_to(point_name:String, speed = default_lerp_speed):
	var lerp_point = lerp_points.get(point_name)
	if lerp_point == null: return
	
	is_lerping = true
	lerp_speed = speed
	lerping_to_point = point_name
	target_pos = lerp_point[0]
	target_rot = lerp_point[1]

func do_lerp(delta):
	var at_pos = current_pos == target_pos
	var at_rot = current_rot.angle_to(target_rot) < .1
	##is this good enough?? ^^
	
	
	#var y = current_pos.ceil()
	if not at_pos:
		transform.origin = transform.origin.slerp(target_pos, lerp_speed*delta)
	if not at_rot:
		self.quaternion = self.quaternion.slerp(target_rot, lerp_speed * delta)
		
	if at_pos and at_rot:
		is_lerping = false
		lerp_speed = default_lerp_speed
		
		current_point = lerping_to_point
		lerping_to_point = ""
		print_debug("lerp done")
