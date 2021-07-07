extends KinematicBody

var speed = 20
var impact_damage = 40
var exploded = false

func _ready():
	hide()

func set_bodies_to_exclude(bodies: Array):
	for body in bodies:
		add_collision_exception_with(body)

func _physics_process(delta):
	var collision: KinematicCollision = move_and_collide(-global_transform.basis.z*speed*delta)
	if collision: 
		var collider = collision.collider
		if collider.has_method("hurt"):
			collider.hurt(impact_damage, -global_transform.basis.z)
		$SmokeParticles.emitting = true
		speed = 0
		$Graphics.hide()
		$CollisionShape.disabled = true

