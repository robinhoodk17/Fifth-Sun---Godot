extends CharacterBody2D


@export var playerid = 1
@export var speed = 800
@onready var character_select_controller: Control = $".."
	
var target_velocity = Vector2.ZERO
var current_button = null
var selected_button = null

	
func _physics_process(_delta):
	if Input.is_action_pressed("Accelerate_%s" % [playerid]):
		if selected_button != null:
			if selected_button == "pilot":
				character_select_controller._on_pilot_canceled(playerid)
			if selected_button == "gunner":
				character_select_controller._on_gunner_canceled(playerid)
				
		if current_button == "pilot":
			character_select_controller._on_pilot_pressed(playerid)
			selected_button = "pilot"
		if current_button == "gunner":
			character_select_controller._on_gunner_pressed(playerid)
			selected_button = "gunner"
		if current_button == "CPU":
			character_select_controller._on_CPU_pressed(playerid)
			selected_button = "CPU"
			
	if Input.is_action_pressed("Brake_%s" % [playerid]):
		if selected_button != null:
			if selected_button == "pilot":
				character_select_controller._on_pilot_canceled(playerid)
			if selected_button == "gunner":
				character_select_controller._on_gunner_canceled(playerid)
		
	
	var direction = Vector2.ZERO
	if Input.is_action_pressed("Go_up_%s" % [playerid]):
		direction.y -= 1
	if Input.is_action_pressed("Go_down_%s" % [playerid]):
		direction.y += 1
	if Input.is_action_pressed("Go_right_%s" % [playerid]):
		direction.x += 1
	if Input.is_action_pressed("Go_left_%s" % [playerid]):
		direction.x -= 1
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	target_velocity.x = direction.x * speed
	target_velocity.y = direction.y * speed
	velocity = target_velocity
	move_and_slide()

#This is the Pilot area
func _on_area_2d_body_entered(body):
	if body.playerid == playerid:
		current_button = "pilot"
		print("entered_%s" %[playerid])
func _on_area_2d_body_exited(body):
	if body.playerid == playerid:
		current_button = null
		print("Exited_%s" %[playerid])


func _on_gunner_area_body_entered(body):
	if body.playerid == playerid:
		current_button = "gunner"
func _on_gunner_area_body_exited(body):
	if body.playerid == playerid:
		current_button = null
		
		
func _on_cpu_area_body_entered(body):
	if body.playerid == playerid:
		current_button = "CPU"
		print("enered CPU")
func _on_cpu_area_body_exited(body):
	if body.playerid == playerid:
		current_button = null
