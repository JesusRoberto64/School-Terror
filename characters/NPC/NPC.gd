extends Spatial

onready var anim = $AnimationPlayer
func _on_area_killed():
	anim.play("Death")
	
	pass # Replace with function body.
