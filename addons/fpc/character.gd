extends CharacterBody3D

# TODO: Add descriptions for each value

@export_category("Character")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0

@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1
@export var immobile : bool = false
@export_file var default_reticle

@export var initial_facing_direction : Vector3 = Vector3.ZERO

@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var HEADBOB_ANIMATION : AnimationPlayer
@export var JUMP_ANIMATION : AnimationPlayer
@export var CROUCH_ANIMATION : AnimationPlayer
@export var SWING_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D

@export_group("Controls")
# We are using UI controls because they are built into Godot Engine so they can be used right away
@export var JUMP : String = "character_jump"
@export var LEFT : String = "character_left"
@export var RIGHT : String = "character_right"
@export var FORWARD : String = "character_forward"
@export var BACKWARD : String = "character_backward"
@export var PAUSE : String = "ui_cancel"
@export var INTERACT : String = "interact"
@export var CROUCH : String
@export var SPRINT : String

# Uncomment if you want full controller support
#@export var LOOK_LEFT : String
#@export var LOOK_RIGHT : String
#@export var LOOK_UP : String
#@export var LOOK_DOWN : String

@export_group("Feature Settings")
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true
@export var jump_animation : bool = true
@export var reticle_enabled : bool = true

@onready var interact_ray: RayCast3D =  $Head/Camera/interact

@export var original_pos:Vector3
@export var original_rot:Vector3
@export var r_melee_ready:Vector3
@export var r_melee_ready_rotation:Vector3
@onready var r_hand:Node3D = $Head/Right_hand
@onready var l_hand:Node3D = $Head/Left_hand
# Member variables
var speed : float = base_speed
var current_speed : float = 0.0
# States: normal, crouching, sprinting
var state : String = "normal"
var attack_state : String = "NOT_ATTACKING"
var prev_attack_state: String
var attack_direction: String
var low_ceiling : bool = false # This is for when the cieling is too low and the player needs to crouch.
var was_on_floor : bool = true

var RETICLE : Control

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

signal swing_done

func halfway_thru_swing():
	emit_signal("halfway_swing")

func _on_halfway_swing():
	print_debug("halfway")

func swing(weapon_state:String, direction:String = "RIGHT"):
	attack_state = weapon_state
	if weapon_state == "READY":
		if direction == "RIGHT":
			#lerp(r_hand.global_position, r_melee_ready, 10)
			SWING_ANIMATION.play("ready_fromright")
		elif direction == "LEFT":
			SWING_ANIMATION.play("ready_fromleft")

	elif weapon_state == "SWING":
		SWING_ANIMATION.play("swing_fromright", .1)


func _on_swing_animation_animation_finished(anim_name):
	swing_done.emit()
	if anim_name == "swing_fromright":
		#SWING_ANIMATION.play_backwards("swing_fromright")
		#SWING_ANIMATION.play("RESET", 1)
		attack_state = "NOT_ATTACKING"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Set the camera rotation to whatever initial_facing_direction is
	if initial_facing_direction:
		HEAD.set_rotation_degrees(initial_facing_direction) # I don't want to be calling this function if the vector is zero
	
	if default_reticle:
		change_reticle(default_reticle)
	
	# Reset the camera position
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")
	SWING_ANIMATION.play("RESET")


func change_reticle(reticle):
	if RETICLE:
		RETICLE.queue_free()
	
	#if reticle_enabled:
	RETICLE = load(reticle).instantiate()
	RETICLE.character = self
	$UserInterface.add_child(RETICLE)
	#change_reticle_visibility(false)

func change_reticle_visibility(make_visible):
	if make_visible:
		RETICLE.visible = true
	else:
		RETICLE.visible = false
		
func _physics_process(delta):
	current_speed = Vector3.ZERO.distance_to(get_real_velocity())
	$UserInterface/DebugPanel.add_property("Speed", snappedf(current_speed, 0.001), 1)
	$UserInterface/DebugPanel.add_property("Target speed", speed, 2)
	$UserInterface/DebugPanel.add_property("Projectiles", get_tree().get_nodes_in_group("projectile").size(), 3)
	$UserInterface/DebugPanel.add_property("Attack State", attack_state, 4)
	
	var cv : Vector3 = get_real_velocity()
	var vd : Array[float] = [
		snappedf(cv.x, 0.001),
		snappedf(cv.y, 0.001),
		snappedf(cv.z, 0.001)
	]
	var readable_velocity : String = "X: " + str(vd[0]) + " Y: " + str(vd[1]) + " Z: " + str(vd[2])
	$UserInterface/DebugPanel.add_property("Velocity", readable_velocity, 3)
	
	# Gravity
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # If the gravity changes during your game, uncomment this code
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	handle_jumping()
	
	var input_dir = Vector2.ZERO
	if !immobile:
		input_dir = Input.get_vector(LEFT, RIGHT, FORWARD, BACKWARD)
	handle_movement(delta, input_dir)
	
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)
	if dynamic_fov:
		update_camera_fov()
	
	if view_bobbing:
		headbob_animation(input_dir)
	
	if jump_animation:
		if !was_on_floor and is_on_floor(): # Just landed
			match randi() % 2:
				0:
					JUMP_ANIMATION.play("land_left")
				1:
					JUMP_ANIMATION.play("land_right")
		
		was_on_floor = is_on_floor() # This must always be at the end of physics_process


func handle_jumping():
	if jumping_enabled:
		if continuous_jumping:
			if Input.is_action_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump")
				velocity.y += jump_velocity
		else:
			if Input.is_action_just_pressed(JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump")
				velocity.y += jump_velocity


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed


func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(SPRINT) and state != "crouching":
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				# If the player is holding sprint before moving, handle that cenerio
				if Input.is_action_pressed(SPRINT) and state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
	
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(CROUCH) and state == "sprinting":
				if state != "crouching":
					enter_slide_state()
			elif Input.is_action_pressed(CROUCH) and state != "sprinting":
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()


# Any enter state function should only be called once when you want to enter that state, not every frame.

func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed

func enter_crouch_state():
	#print("entering crouch state")
	var prev_state = state
	state = "crouching"
	speed = crouch_speed
	CROUCH_ANIMATION.play("crouch")

func enter_slide_state():
	var prev_state = state
	state = "sliding"
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed


func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)


func headbob_animation(moving):
	if moving and is_on_floor():
		var use_headbob_animation : String
		match state:
			"normal","crouching":
				use_headbob_animation = "walk"
			"sprinting":
				use_headbob_animation = "sprint"
			#"sliding":
				#use_headbob_animation = "slide"
		
		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true
		
		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.75
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
			# This code is extremely performant but it makes no sense.
		
	else:
		HEADBOB_ANIMATION.play("RESET", 0.25)
		HEADBOB_ANIMATION.speed_scale = 1


func _process(delta):
	$UserInterface/DebugPanel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
	var status : String = state
	if !is_on_floor():
		status += " in the air"
	$UserInterface/DebugPanel.add_property("State", status, 4)
	
	if Input.is_action_just_pressed(PAUSE):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	var collider = interact_ray.get_collider()
	if collider and collider.is_in_group("interactable") and collider.is_interactable:
		RETICLE.update_text(collider.interact_type + " " + collider.interact_name)
		change_reticle_visibility(true)
	else:
		change_reticle_visibility(false)
	# Uncomment if you want full controller support
	#var controller_view_rotation = Input.get_vector(LOOK_LEFT, LOOK_RIGHT, LOOK_UP, LOOK_DOWN)
	#HEAD.rotation_degrees.y -= controller_view_rotation.x * 1.5
	#HEAD.rotation_degrees.x -= controller_view_rotation.y * 1.5


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		HEAD.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		HEAD.rotation_degrees.x -= event.relative.y * mouse_sensitivity
	
	if Input.is_action_just_pressed(INTERACT):
		var collider = interact_ray.get_collider()
		if collider and collider.is_in_group("interactable") and collider.is_interactable:
			collider.interact(self)
			


