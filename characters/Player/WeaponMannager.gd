extends Spatial

enum WEAPONS_SLOTS {MACHETE,MACHINE_GUN,SHOTGUN,ROCKET_LAUNCHER}
var slots_unlocked = {
	WEAPONS_SLOTS.MACHETE: true,
	WEAPONS_SLOTS.MACHINE_GUN: true,
	WEAPONS_SLOTS.SHOTGUN: false,
	WEAPONS_SLOTS.ROCKET_LAUNCHER: false,
} 

onready var anim_player = $AnimationPlayer
onready var weapons = $Weapons.get_children()
onready var alert_area_hearing = $AlertAreaHearing
onready var alert_area_los = $AlertAreaLos

var cur_slot = 0
var cur_weapon = null
var fire_point = Spatial
var bodies_to_exclude : Array = []

signal ammo_changed 

func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, _bodies_to_exclude)
	
	weapons[WEAPONS_SLOTS.MACHINE_GUN].connect("fired",self, "alert_nearby_enemies")
	weapons[WEAPONS_SLOTS.SHOTGUN].connect("fired",self, "alert_nearby_enemies")
	weapons[WEAPONS_SLOTS.ROCKET_LAUNCHER].connect("fired",self, "alert_nearby_enemies")
	
	for weapon in weapons:
		weapon.connect("fired",self,"emmit_ammo_changed_signal")
	
	switch_to_weapon_slot(WEAPONS_SLOTS.MACHINE_GUN)

func attack(attack_input_just_pressed : bool, attack_input_held : bool):
	if cur_weapon.has_method("attack"):
		cur_weapon.attack(attack_input_just_pressed,attack_input_held)
	

func switch_to_next_weapon():
	cur_slot  = (cur_slot +1) % slots_unlocked.size()
	if !slots_unlocked[cur_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(cur_slot)

func switch_to_last_weapon():
	cur_slot  = posmod((cur_slot -1),slots_unlocked.size())
	if !slots_unlocked[cur_slot]:
		switch_to_last_weapon()
	else:
		switch_to_weapon_slot(cur_slot)

func switch_to_weapon_slot(slot_ind: int):
	if slot_ind < 0 or slot_ind >= slots_unlocked.size():
		return
	if !slots_unlocked[cur_slot]:
		return
	disable_all_weapons()
	cur_weapon = weapons[slot_ind]
	if cur_weapon.has_method("set_active"):
		cur_weapon.set_active()
	else:
		cur_weapon.show()
	emmit_ammo_changed_signal()

func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			weapon.hide()

func update_animation(velocity: Vector3, grounded: bool):
	if cur_weapon.has_method("is_idle") and !cur_weapon.is_idle():
		anim_player.play("idle")
	if !grounded or velocity.length() < 6.0:
		anim_player.play("idle",0.08)
	anim_player.play("moving")

func alert_nearby_enemies():
	var nearby_enemies = alert_area_los.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert()
	nearby_enemies = alert_area_hearing.get_overlapping_bodies()
	for nearby_enemy in nearby_enemies:
		if nearby_enemy.has_method("alert"):
			nearby_enemy.alert(false)

func get_pickup(pickup_type,ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.MACHNE_GUN:
			if !slots_unlocked[WEAPONS_SLOTS.MACHINE_GUN]:
				slots_unlocked[WEAPONS_SLOTS.MACHINE_GUN] = true
				switch_to_weapon_slot(WEAPONS_SLOTS.MACHINE_GUN)
			weapons[WEAPONS_SLOTS.MACHINE_GUN].ammo += ammo
		Pickup.PICKUP_TYPES.MACHINE_GUN_AMMO:
			weapons[WEAPONS_SLOTS.MACHINE_GUN].ammo += ammo
		Pickup.PICKUP_TYPES.SHOTGUN:
			if !slots_unlocked[WEAPONS_SLOTS.SHOTGUN]:
				slots_unlocked[WEAPONS_SLOTS.SHOTGUN] = true
				switch_to_weapon_slot(WEAPONS_SLOTS.SHOTGUN)
			weapons[WEAPONS_SLOTS.SHOTGUN].ammo += ammo
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			weapons[WEAPONS_SLOTS.SHOTGUN].ammo += ammo
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			if !slots_unlocked[WEAPONS_SLOTS.ROCKET_LAUNCHER]:
				slots_unlocked[WEAPONS_SLOTS.ROCKET_LAUNCHER] = true
				switch_to_weapon_slot(WEAPONS_SLOTS.ROCKET_LAUNCHER)
			weapons[WEAPONS_SLOTS.ROCKET_LAUNCHER].ammo += ammo
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
			weapons[WEAPONS_SLOTS.ROCKET_LAUNCHER].ammo += ammo
	emmit_ammo_changed_signal()

func emmit_ammo_changed_signal():
	emit_signal("ammo_changed",cur_weapon.ammo)
	















