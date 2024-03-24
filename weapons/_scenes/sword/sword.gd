extends Node3D
#@export var range:float = .7
#@export var width:float = 1.0
#@export var height:float = .2
#@onready var aniomation_plr:AnimationPlayer = $AnimationPlayer

@export var weapon_stats:WeaponStats
@onready var hurtbox_coll:CollisionShape3D = $hurtbox/hurtbox_collision
@onready var player

var state: String

func _ready():
	if not player:
		player = get_parent_player(self)
	print_debug("redddee")
func _unhandled_input(event):
	if not state == "READY" and Input.is_action_pressed("main_action"):
		player.swing("ready_fromright")
		state = "READY"
	if Input.is_action_just_released("main_action"):
		player.swing("swing_fromright")
		state = "SWING_FROMRIGHT"

func get_parent_player(parent):
	var curr_parent = parent.get_parent()
	if curr_parent is CharacterBody3D:
		return curr_parent
	else:
		get_parent_player(curr_parent)
