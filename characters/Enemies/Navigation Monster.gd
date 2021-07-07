extends Navigation

onready var patrol_Points = $PatrolPoints
var monsters = []

func _ready():
	
	var childrens = get_children()
	
	for i in childrens:
		if i.is_in_group("monsters"):
			for y in patrol_Points.get_children():
				if y.id == i.id:
					i.patrol_points = y.arr_Translate
			pass
		pass
	pass
