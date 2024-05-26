extends Node
enum Pilotbehaviors {normal, straight}
enum Gunnerbehaviors {normal, doNothing}

var Pilot = null
var Gunner = null

var pilotBehavior = Pilotbehaviors.normal
var gunnerBehavior = Gunnerbehaviors.normal
var Screen_ratio = 1.78
var NextScene = "res://Scenes/Scene1.tscn"
