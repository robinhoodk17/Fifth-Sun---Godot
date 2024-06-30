extends Node

enum shipNames {BlueLightning}
@export_group("startPositions")
@export var shipPositions : Array[Marker3D]
@export var whichShipGoesWhere : Array[shipNames]
@export_group("preFabs")
@export var shipPrefabs : Array[PackedScene]
@export var shipCameraPrefab : PackedScene
@export var turretCameraPrefab : PackedScene
@export var GridContainerPrefab_2P : PackedScene
@export var GridContainerPrefab_4P : PackedScene
var player1Position : int = GlobalVariables.Player1Position
var player1Ship
var player2Position : int = GlobalVariables.Player2Position
var player2Ship
var initialized : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	for i in range(0,shipPositions.size()):
		shipPositions[i].queue_free()
		var ship_being_Instantiated = whichShipGoesWhere[i] -1
		var newInstance = shipPrefabs[ship_being_Instantiated].instantiate()
		get_parent().add_child(newInstance)
		newInstance.global_position = shipPositions[i].global_position
		newInstance.global_basis = shipPositions[i].global_basis
		if i == player1Position:
			newInstance.Pilot = GlobalVariables.Pilot 
			newInstance.get_node("Turret/Turret_body_y").Gunner = GlobalVariables.Gunner 
			newInstance.initialize()
			player1Ship = newInstance
			print(i)
		if i == player2Position and i != player1Position:
			player2Ship = newInstance
			newInstance.Pilot = GlobalVariables.Pilot2 
			newInstance.get_node("Turret/Turret_body_y").Gunner = GlobalVariables.Gunner2 
#region New Code Region
#we spawn the UI for 2 or 4 players, depending on the global variables. it is still not working for 4 players
	if GlobalVariables.Player2Position > 0:
		var newInstance = GridContainerPrefab_4P.instantiate()
		$".".add_child.call_deferred(newInstance)
		newInstance.reparent($"..")
	else:
		var Camera1 = shipCameraPrefab.instantiate()
		var Camera2 = turretCameraPrefab.instantiate()
		var newInstance = GridContainerPrefab_2P.instantiate()
		get_parent().add_child(newInstance)
		newInstance.get_node("SubViewportContainer/SubViewport").add_child(Camera1)
		newInstance.get_node("SubViewportContainer2/SubViewport").add_child(Camera2)
		newInstance.Camera1 = Camera1
		newInstance.Camera2 = Camera2
		newInstance.ship_body = player1Ship
		newInstance.initialize()
#endregion
	queue_free()
