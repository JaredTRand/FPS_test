extends CharacterBody3D

var health:float = 300
@onready var blood:GPUParticles3D = $Blood

func _process(delta):
	pass
	#check_health()

func take_damage(damage:float):
	blood.restart()
	health -= damage
	check_health()

func check_health():
	if health <= 0:
		die()
		
func die():
	queue_free()

func knock_back():
	pass
