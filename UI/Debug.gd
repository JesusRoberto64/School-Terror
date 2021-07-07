extends CanvasLayer


var FPS: float

func _ready():
	pass # Replace with function body.

func _process(_delta):
	#FPS = Performance.get_monitor(Performance.TIME_FPS)
	$Label.text = str(Performance.get_monitor(Performance.TIME_FPS)) + " FPS"
	$Label2.text = str(Performance.get_monitor(Performance.TIME_FPS)) + " FPS"
	pass
