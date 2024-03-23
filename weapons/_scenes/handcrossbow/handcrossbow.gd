extends Node3D

@onready var muzzle:Node3D = $weapon_node/Muzzle
@onready var timer = $Timer
@onready var fly_timer = $flyTimer
@onready var bolt := preload("res://weapons/_scenes/arrow.tscn")

var can_shoot:bool = true
var loaded:bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	load_bolt()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("main_action"):
		shoot()

func shoot():
	#timer.start()
	if loaded and can_shoot:
		var x = bolt.instantiate()
		muzzle.add_child(x)
		#muzzle.remove_child(x)
		#x.shoot()
		#can_shoot = false
		


func _on_timer_timeout():
	fly_timer.start()
	#bolt.visible = false
	can_shoot = true

func _on_fly_timer_timeout():
	#bolt.visible = true
	can_shoot = false

func load_bolt():
	#loaded_bolt = bolt.instantiate()
	#muzzle.add_child(loaded_bolt)
	loaded = true
