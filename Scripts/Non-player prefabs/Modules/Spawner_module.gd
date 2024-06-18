extends Node3D

@export var spawnedObject : PackedScene
@export var objectCount : int

var objectList


# Called when the node enters the scene tree for the first time.
func preSpawn(objectAmount = objectCount):
	for i in objectAmount:
		var newInstance = spawnedObject.instantiate()
		get_parent().add_child(newInstance)
		newInstance.position = Vector3(0,0,0)
		objectList.append(newInstance)
		newInstance.set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
