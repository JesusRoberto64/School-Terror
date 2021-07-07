extends Area

var enemies: Array = []
var readed_Enemies = false

func _ready():
	pass

func _process(_delta):
	if !readed_Enemies:
		enemies = get_tree().get_nodes_in_group("monsters")
		readed_Enemies = true
	pass

func enemy_within_angle(cur_enemy,angle: float):
	var enemy = enemies[cur_enemy]
	var dir_to_enemy = global_transform.origin.direction_to(enemy.global_transform.origin)
	var forwards = global_transform.basis.x 
	
	
	
	pass

