extends Control

@onready var redzone = $Redzone
@onready var Pin = $Pin
@onready var ResultLabel = $ResultLabel
@onready var NextButton = $NextButton

var baseSpeed = 300.0
var speed = baseSpeed
var direction = 1
var pinStopped = false
var level = 1
var maxLevel = 3

func _ready():
		#updateSpeed()
		#randomizeZone()
		NextButton.visible = false
		#NextButton.pressed.connect(on_next_pressed)
func _process(delta):
		if pinStopped:
			return
		Pin.position.x+= direction * speed * delta
		if Pin.position.x <= -300 or Pin.position.x >= 200:
			direction*=-1
		
