extends Node3D
@export var RouteNode : Node3D
@export var PreviousNode : Node3D = null
@export var NextNode : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	RouteNode.PreviousNode = PreviousNode
	RouteNode.NextNode = NextNode
