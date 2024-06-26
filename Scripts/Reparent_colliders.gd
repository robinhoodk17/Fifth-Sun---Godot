extends Node3D
@export var collidersBodies : Array[CollisionShape3D]

func move_collider(collider: Node3D):
	remove_child(collider)
	var ship = get_parent()
	ship.add_child(collider)
	ship.BodyCollider.append(collider)
# Called when the node enters the scene tree for the first time.
func _ready():
	for collider in collidersBodies:
		call_deferred("move_collider", collider)
