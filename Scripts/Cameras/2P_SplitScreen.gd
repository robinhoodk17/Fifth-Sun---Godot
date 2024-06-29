extends GridContainer

@onready var viewport1: SubViewport = $SubViewportContainer/SubViewport
@onready var viewport2: SubViewport = $SubViewportContainer2/SubViewport
@onready var Camera1: Camera3D = get_node("../Ship/Marker3D/Camera3D")
@onready var Camera2: Camera3D = get_node("../Ship/Turret/Turret_body_y/Turret_body_x/Camera2")

# Called when the node enters the scene tree for the first time.
func _ready():
	var Camera_rid1 = Camera1.get_camera_rid()
	var Camera_rid2 = Camera2.get_camera_rid()
	var viewport_rid1 = viewport1.get_viewport_rid()
	var viewport_rid2 = viewport2.get_viewport_rid()
	RenderingServer.viewport_attach_camera(viewport_rid1, Camera_rid1)
	RenderingServer.viewport_attach_camera(viewport_rid2, Camera_rid2)
	var ship_body : Ship = get_node("../Ship")
	var ship_Health_Bar = $SubViewportContainer/SubViewport/Health
	ship_Health_Bar.init_health(ship_body.maxHealth)
	
