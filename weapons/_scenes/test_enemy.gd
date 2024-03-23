extends CharacterBody3D

var health:float = 300

func _process(delta):
	check_health()

func take_damage(damage:float):
	health -= damage

func check_health():
	if health <= 0:
		die()
		
func die():
	queue_free()
