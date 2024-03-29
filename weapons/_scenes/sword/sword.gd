extends Node3D
#@export var range:float = .7
#@export var width:float = 1.0
#@export var height:float = .2
#@onready var aniomation_plr:AnimationPlayer = $AnimationPlayer

@export var weapon_stats:WeaponStats
@onready var hurtbox_coll:CollisionShape3D = $hurtbox/hurtbox_collision
@onready var hitbox:Area3D = $weapon_node/model/HitBox
@onready var player

var state: String
var prev_state: String

func _ready():
	if not player:
		player = get_parent_player(self)
	print_debug("redddee")
	
func _unhandled_input(event):
	if not state == "READY" and not state == "SWING" and Input.is_action_pressed("main_action"):
		player.swing("READY")
	if not state == "SWING" and Input.is_action_just_released("main_action"):
		player.swing("SWING")
	

func get_parent_player(parent):
	var curr_parent = parent.get_parent()
	if curr_parent is CharacterBody3D:
		return curr_parent
	else:
		get_parent_player(curr_parent)


func _on_hit_box_body_entered(body):
	if body != player and body.has_method("take_damage"):
		body.take_damage(weapon_stats.damage)

func _process(delta):
	player.prev_attack_state = state
	state = player.attack_state
	
	if state == "SWING":
		hitbox.monitoring == true
		hitbox.monitorable == true
	else:
		hitbox.monitoring == false
		hitbox.monitorable == false
