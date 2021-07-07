extends RayCast

func _physics_process(_delta):
	
	#print(get_collider())
	 
	var enemy = get_collider()
	
	if enemy != null:
		if enemy as KinematicBody:
			print("enemy")
	
	pass
