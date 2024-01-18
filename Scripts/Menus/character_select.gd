extends Control

var Pilot = null
var Gunner = null
var CPU = null


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (Pilot != null or Gunner != null) and CPU != null:
		GlobalVariables.Pilot = Pilot
		GlobalVariables.Gunner = Gunner
		get_tree().change_scene_to_file(GlobalVariables.NextScene)
	if Pilot != null and Gunner != null:
		GlobalVariables.Pilot = Pilot
		GlobalVariables.Gunner = Gunner
		get_tree().change_scene_to_file(GlobalVariables.NextScene)


func _on_pilot_pressed(playerid):
	if Pilot == null:
		Pilot = playerid
		print("Pilot_%s" % [Pilot])

func _on_pilot_canceled(playerid):
	if Pilot == playerid:
		Pilot = null
		print("Pilot canceled")

func _on_gunner_pressed(playerid):
	if Gunner == null:
		Gunner = playerid
		print("Gunner_%s" % [Gunner])
		print(Gunner)
	
func _on_gunner_canceled(playerid):
	if Gunner == playerid:
		Gunner = null
		print("Gunner canceled")
		
func _on_CPU_pressed(playerid):
	CPU = playerid
	print("CPU pressed")
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
