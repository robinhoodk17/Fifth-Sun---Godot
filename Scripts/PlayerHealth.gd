extends SubViewportContainer


@export var ship_Health_Bar : ProgressBar
var ship_body : Ship

func takeDamage():
	ship_Health_Bar.health = ship_body.currentHealth
