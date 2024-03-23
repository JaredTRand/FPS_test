extends Node3D
#@export var range:float = .7
#@export var width:float = 1.0
#@export var height:float = .2
#@onready var aniomation_plr:AnimationPlayer = $AnimationPlayer

@export var weapon_stats:WeaponStats
@onready var hurtbox_coll:CollisionShape3D = $hurtbox/hurtbox_collision

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
