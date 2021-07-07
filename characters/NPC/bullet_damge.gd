extends Area

var blood_spray = preload("res://Effects/BloodSpray.tscn")
signal killed

func hurt(damage: int, dir: Vector3):
	var blood_spray_inst = blood_spray.instance()
	get_tree().get_root().add_child(blood_spray_inst)
	blood_spray_inst.global_transform.origin = global_transform.origin
	
	emit_signal("killed")
	pass

