extends Marker3D

var Ship_body : CharacterBody3D
var Ydamping : Array[float]
var YdampingCounter : int = 0
var dampingFrames : int = 7
var lerpSpeed = .2
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in dampingFrames:
		Ydamping.append(position.y)
	Ship_body = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if YdampingCounter < dampingFrames - 1:
		YdampingCounter += 1
	else:
		YdampingCounter = 0
	Ydamping[YdampingCounter] = Ship_body.position.y
	var yMean = 0
	for i in Ydamping:
		yMean += i
	yMean /= Ydamping.size()
	if Ship_body.boosting:
		lerpSpeed = .2
		position = position.lerp(Ship_body.position,lerpSpeed)
	else:
		if lerpSpeed < .6:
			lerpSpeed = lerp(lerpSpeed,.6,.5*delta)
		var targetPosition = Vector3(Ship_body.position.x, yMean, Ship_body.position.z)
		position = position.lerp(targetPosition,lerpSpeed)
	
	var a = Quaternion(Ship_body.transform.basis.orthonormalized())
	var b = Quaternion(transform.basis.orthonormalized())
	var c = b.slerp(a, 0.1)
	transform.basis = Basis(c)

