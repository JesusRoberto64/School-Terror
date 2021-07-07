extends RayCast

signal normal_info
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	
	emit_signal("normal_info",get_collision_normal())
	pass
