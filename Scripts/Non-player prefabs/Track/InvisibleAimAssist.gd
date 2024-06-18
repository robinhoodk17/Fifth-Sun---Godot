extends StaticBody3D

@export var mesh : MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready():
	mesh.visible = false
