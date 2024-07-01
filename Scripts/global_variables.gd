extends Node
enum Pilotbehaviors {normal, straight, doNothing}
enum Gunnerbehaviors {normal, doNothing}

var Pilot = 2
var Gunner = 1
var Pilot2 = null
var Gunner2 = null
var Player1Position = 1
var Player2Position = 0

var MotionBlurIntensity = .1
var FOV = 90
var pilotBehavior = Pilotbehaviors.normal
var gunnerBehavior = Gunnerbehaviors.normal
var Screen_ratio = 1.78
var NextScene = "res://Scenes/Track2.tscn"
