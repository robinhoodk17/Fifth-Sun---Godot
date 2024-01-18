extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.






func _on_campaign_pressed():
	pass # Replace with function body.


func _on_race_pressed():
	get_tree().change_scene_to_file("res://Scenes/character_select.tscn")
	pass # Replace with function body.


func _on_fight_pressed():
	pass # Replace with function body.


func _on_options_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()
