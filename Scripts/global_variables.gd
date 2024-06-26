extends Node
enum Pilotbehaviors {normal, straight}
enum Gunnerbehaviors {normal, doNothing}

var Pilot = 1
var Gunner = null

var MotionBlurIntensity = .1
var FOV = 90
var pilotBehavior = Pilotbehaviors.normal
var gunnerBehavior = Gunnerbehaviors.normal
var Screen_ratio = 1.78
var NextScene = "res://Scenes/Track2.tscn"
