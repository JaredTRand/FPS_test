extends Node3D

var bolt = self
@onready var despawn_timer = $despawn
@onready var stuck_pointy_area = $StuckWithPointy

var damage:float = 100
var speed = 30

var current_position

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	shoot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func shoot():
	bolt.apply_impulse(-transform.basis.x  * speed, transform.basis.x)


func _on_despawn_timeout():
	#maybe check if velocity is higher than something? Like if bolt hit, but them rolled off cliff. we'd want it to keep going.
	bolt.sleeping = true
	stuck_pointy_area.monitoring = false


func _on_body_entered(body):
	# bolt hit collider
	
	
	## LATER can try to make something so that when collides with something "stickable", 
	## the rigid body is deleted, and just a meshinstance is put in it's place, parented to the collided body
	#current_position = global_transform
	#body.add_child(bolt)
	#bolt.global_transform = current_position
	pass


func _on_stuck_with_pointy_body_entered(body):
	if body == bolt or body.is_in_group("projectile"): return
	
	if despawn_timer.is_stopped():
		despawn_timer.start()
	
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("stickable"):
		bolt.freeze = true


func diable_bolt():
	stuck_pointy_area.monitorable = false
	stuck_pointy_area.monitoring = false
