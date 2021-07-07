extends KinematicBody

onready var character_mover = $CharEnemyMover
onready var anim_player = $Graphics/AnimationPlayer
onready var health_mannager = $HealthMannager
onready var nav: Navigation = get_parent()

enum STATES {IDLE, CHASE, ATTACK, DEAD,PATROL}
var cur_state = STATES.IDLE

var player = null
var path = []

export var sight_angle = 90.0
export var turn_speed = 360.0

export var attack_angle = 5.0
export var attack_range = 2.0
export var attack_rate = 0.5
export var attack_anim_speed_mod = 0.5
export var speed = 5.0
var attack_timer : Timer
var can_attack = true

signal attack

#Patrol points 
var patrol_points: PoolVector3Array = [] 
export var id = 0
var cur_point = 0
var indx_pont = 0

func _ready():
	add_to_group("monsters")
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout",self,"finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	player = get_tree().get_nodes_in_group("player")[0]
	var bone_attachments =  $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt",self,"hurt")
			pass
	health_mannager.connect("dead",self,"set_state_dead")
	health_mannager.connect("gibbed",$Graphics,"hide")
	character_mover.init(self)
	set_state_idle()
	#set_state_patrol()
	
	# Add patrol points 
	

func _process(delta):
	
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)
		STATES.PATROL:
			process_patrol_state(delta)
			pass

func set_state_idle():
	cur_state = STATES.IDLE
	anim_player.play("idle_loop")

func set_state_chase():
	cur_state = STATES.CHASE
	anim_player.play("walk_loop", 0.2)
	character_mover.max_speed = 10.0
	character_mover.move_accel = 8.0

func set_state_attack():
	cur_state = STATES.ATTACK

func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.play("die")
	character_mover.freeze()
	$CollisionShape.disabled = true

func set_state_patrol():
	cur_state = STATES.PATROL
	anim_player.play("walk_loop", 0.2)
	character_mover.max_speed = 20.0
	character_mover.move_accel = 5.0
	pass

func process_state_idle(delta):
	if can_see_player():
		set_state_chase()
	pass

func process_state_chase(delta):
	if within_dist_of_player(attack_range) and has_los_player():
		set_state_attack()
	
	set_nav_movement(delta,player.global_transform.origin)
	
	#OLD SYSTEM 
#	var player_pos = player.global_transform.origin
#	var our_pos = global_transform.origin  
#	path = nav.get_simple_path(our_pos,player_pos)
#	var goal_pos = player_pos
#	if path.size() > 1:
#		goal_pos = path[1]
#	var dir = goal_pos - our_pos 
#	dir.y = 1
#	character_mover.set_move_vec(dir)
#	face_dir(dir,delta)

func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO)
	
	if can_attack:
		if !within_dist_of_player(attack_range) or !can_see_player():
			set_state_chase()
		elif !player_whithin_angle(attack_angle): 
			face_dir(global_transform.origin.direction_to(player.global_transform.origin),delta)
		else:
			start_attack()

func process_state_dead(delta):
	pass

func process_patrol_state(delta):
	if patrol_points.size() <= 0:
		cur_state = STATES.IDLE
		return
	
	if can_see_player():
		#print("ya te vi")
		#return
		pass
	
	set_nav_movement(delta,patrol_points[cur_point])
	
	if global_transform.origin.distance_to(patrol_points[cur_point]) < 0.5:
		indx_pont += 1
		cur_point = indx_pont%patrol_points.size()
		#print("Cerquita")
		pass
	
	
	pass

func hurt(damage: int, dir: Vector3):
	if cur_state == STATES.IDLE:
		set_state_chase()
	health_mannager.hurt(damage, dir)
	pass

func start_attack():
	can_attack = false
	anim_player.play("attack",-1, attack_anim_speed_mod)
	attack_timer.start()
	#aimer.aim_at_pos(player.global_transform.origin + Vector3.UP)

func emmit_attack_signal():
	emit_signal("attack")

func finish_attack():
	can_attack = true

func can_see_player():
	#var dir_to_player =  global_transform.origin.direction_to(player.global_transform.origin)
	#var forwards = global_transform.basis.z
	return player_whithin_angle(sight_angle) and has_los_player()

func player_whithin_angle(angle: float):
	var dir_to_player =  global_transform.origin.direction_to(player.global_transform.origin)
	var forwards = global_transform.basis.z
	return rad2deg(forwards.angle_to(dir_to_player)) < angle

func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP
	var player_position = player.global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_position, [], 1)
	if result:
		return false
	return true

func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z)
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_right
		pass

func alert(check_los=true):
	if cur_state != STATES.IDLE:
		return
	if check_los and !has_los_player():
		return
	set_state_chase() 

func within_dist_of_player(dis: float):
	return global_transform.origin.distance_to(player.global_transform.origin) < attack_range

func set_nav_movement(delta,final_Pos):
	var direction = Vector3()
	var step_size = delta * speed
	
	#var player_pos =  player.global_transform.origin 
	var our_pos = translation#global_transform.origin  
	path = nav.get_simple_path(our_pos,final_Pos,true)
	
	if path.size() > 1:
		var destination = path[1] 
		direction = destination - translation
		
		if step_size > direction.length():
			step_size = direction.length()
			path.remove(1)
		
		#move_and_slide(direction.normalized()*speed,Vector3.UP,true,4,70) # simple move in script
		character_mover.set_move_vec(direction)
		
		direction.y = 0
		if direction:
			var look_at_point = translation - direction.normalized()
			look_at(look_at_point,Vector3.UP)
	

