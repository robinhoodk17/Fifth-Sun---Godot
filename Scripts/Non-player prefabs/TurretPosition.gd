extends Node3D
@export var Ship_body : CharacterBody3D

func _process(delta):
	position = Ship_body.position
