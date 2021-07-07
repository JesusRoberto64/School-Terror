extends KinematicBody

var hotkeys = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}

export var mouse_sens = 0.5
onready var camera = $Camera
onready var character_mover = $CharcaterMover
onready var health_mannager = $HealthMannager
onready var weapon_mannager = $Camera/WeaponMannager
onready var pickup_mannager = $PickupMannager
var dead =  false 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character_mover.init(self)
	
	pickup_mannager.max_player_health = health_mannager.max_health
	health_mannager.connect("helath_changed",pickup_mannager,"update_players_health")
	pickup_mannager.connect("got_pickup",weapon_mannager,"get_pickup")
	pickup_mannager.connect("got_pickup",health_mannager,"get_pickup")
	health_mannager.init()
	health_mannager.connect("dead",self,"kill")
	weapon_mannager.init($Camera/FirePoint,[self])

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if dead:
		return
	
	var move_vec = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backgards"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_rigth"):
		move_vec += Vector3.RIGHT
	if Input.is_action_pressed("move_left"):
		move_vec += Vector3.LEFT
	character_mover.set_move_vec(move_vec)
	if Input.is_action_just_pressed("jump"):
		character_mover.jump()
	
	weapon_mannager.attack(Input.is_action_just_pressed("attack"), Input.is_action_pressed("attack"))

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x,-90,90)
	if event is InputEventKey and event.is_pressed():
		if event.scancode in hotkeys:
			weapon_mannager.switch_to_weapon_slot(hotkeys[event.scancode])
			pass
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_DOWN:
			weapon_mannager.switch_to_next_weapon()
		if event.button_index == BUTTON_WHEEL_UP:
			weapon_mannager.switch_to_last_weapon()

func hurt(damage,dir):
	health_mannager.hurt(damage,dir)
	

func heal(amount):
	health_mannager.heal(amount)

func kill():
	dead = true
	character_mover.freeze()


