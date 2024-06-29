extends Node3D
@onready var healthBar = $SubViewport/Health
var health = 0 : set = _set_health

func _set_health(new_health):
	healthBar.health = new_health

func init_health(health):
	healthBar.init_health(health)
