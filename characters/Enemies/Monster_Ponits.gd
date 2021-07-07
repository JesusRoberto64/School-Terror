extends Spatial


export var id = 0

var arr_Translate: PoolVector3Array = []

func _ready():
	for i in get_children():
		arr_Translate.append(i.translation)
	
