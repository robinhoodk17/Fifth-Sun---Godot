extends GridContainer

@onready var viewport1: SubViewport = $SubViewportContainer/SubViewport
@onready var viewport2: SubViewport = $SubViewportContainer2/SubViewport
@onready var ship_Health_Bar = $SubViewportContainer/SubViewport/Health
@onready var speedoMeter = $"SubViewportContainer/SubViewport/MarginContainer/UI pilot"
var Camera1 : Marker3D
var Camera2: Marker3D
var ship_body

# Called when the node enters the scene tree for the first time.
func initialize():
	Camera1.initialize(ship_body)
	Camera1.global_position = ship_body.global_position
	Camera1.global_basis = ship_body.global_basis
	
	var turret = ship_body.get_node("Turret/Turret_body_y/Turret_body_x")
	Camera2.initialize(turret)
	Camera2.global_position = ship_body.global_position
	Camera2.global_basis = ship_body.global_basis
	
	ship_Health_Bar.init_health(ship_body.maxHealth)
	ship_body.damageSignal.connect(takeDamage)
	speedoMeter.ship = ship_body
func takeDamage():
	ship_Health_Bar.health = ship_body.currentHealth
