extends Node3D
#@export var range:float = .7
#@export var width:float = 1.0
#@export var height:float = .2
#@onready var aniomation_plr:AnimationPlayer = $AnimationPlayer

var weapon_stats:WeaponStats
@onready var hurtbox_coll:CollisionShape3D = $hurtbox/hurtbox_collision
@onready var hitbox:Area3D = $weapon_node/model/HitBox

var player
@onready var return_timer:Timer = $return

var state: String
var prev_state: String
var direction: String

var need_pos_return: bool = false

func _ready():
	if not player:
		player = weapon_stats.player
		player.swing_done.connect(_on_swing_done)
	print_debug("redddee")
	
func _unhandled_input(event):
	if not state == "READY" and not state == "SWING" and Input.is_action_pressed("main_action"):
		if prev_state == "SWING":
			direction = "LEFT"
		else:
			direction = "RIGHT"
			
		player.swing("READY", direction)
	elif not state == "SWING" and Input.is_action_just_released("main_action"):
		player.swing("SWING")


func _on_hit_box_body_entered(body):
	if body != player and body.has_method("take_damage"):
		body.take_damage(weapon_stats.damage)
		body.knock_back()

func _process(delta):
	player.prev_attack_state = state
	prev_state = state
	state = player.attack_state
	
	if state == "SWING":
		hitbox.monitoring = true
		hitbox.monitorable = true
	else:
		hitbox.monitoring = false
		hitbox.monitorable = false
		
	if need_pos_return and return_timer.is_stopped() and state == "SWING_DONE":
		return_timer.start()
	elif state != "NOT_ATTACKING" and state != "SWING_DONE":
		return_timer.stop()

func _on_swing_done():
	need_pos_return = true
	return_timer.start()
func _on_return_timeout():
	player.return_melee()
	player.attack_state = "NOT_ATTACKING"
	need_pos_return = false
