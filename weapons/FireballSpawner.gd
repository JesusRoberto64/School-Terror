extends Spatial

var fireball = preload("res://weapons/Fireball.tscn")

var bodies_to_exclude = []
var damage = 1

func set_damage(_damage: int):
	damage = _damage


func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude


func fire():
	for i in range(3):
		var fireball_inst = fireball.instance()
		fireball_inst.set_bodies_to_exclude(bodies_to_exclude)
		get_tree().get_root().add_child(fireball_inst)
		fireball_inst.global_transform = global_transform 
		fireball_inst.impact_damage = damage
		fireball_inst.transform.origin += Vector3.LEFT * i 
		#fireball_inst.position +=  Vector3.LEFT
