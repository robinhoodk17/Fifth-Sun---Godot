extends Area3D

@export var cooldown = 5
@export var spawnedObject : PackedScene
@export var objectCount : int = 5
@export var delay : float = 0.5
@onready var cooldownCount = cooldown
var objectList : Array[Node3D] = []
@export var activeObject : int = 0
var waitingfordelay = false

func activateObject():
	if activeObject < objectCount-1:
		objectCount += 1
		objectList[activeObject].set_process(true)
		objectList[activeObject].set_physics_process(true)
		objectList[activeObject].startup()
		objectList[activeObject].visible = true
		objectList[activeObject].global_position = position
	else:
		objectCount = 0
		objectList[activeObject].set_process(true)
		objectList[activeObject].set_physics_process(true)
		objectList[activeObject].startup()
		objectList[activeObject].visible = true
		objectList[activeObject].global_position = position
func spawnObjects(objectAmount = objectCount):
	for i in objectAmount:
		var newInstance : Node3D = spawnedObject.instantiate()
		$".".add_child.call_deferred(newInstance)
		newInstance.position = position
		objectList.append(newInstance)
		newInstance.set_process(false)
		newInstance.visible = false
		newInstance.set_physics_process(false)
		

func _ready():
	spawnObjects()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cooldownCount += delta
	if waitingfordelay and cooldownCount >= delay:
		activateObject()
		waitingfordelay = false

func _on_body_entered(body):
	if body.is_in_group("Ship") and cooldownCount >= cooldown:
		cooldownCount = 0
		objectList[activeObject].target = body
		waitingfordelay = true
