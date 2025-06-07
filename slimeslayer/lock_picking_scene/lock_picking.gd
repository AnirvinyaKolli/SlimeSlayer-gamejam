extends Control

@onready var animation: AnimationPlayer = $LockPick/AnimationPlayer
@onready var redzone = $Redzone
@onready var Pin = $Pin
@onready var ResultLabel = $ResultLabel
@onready var NextButton = $NextButton

var baseSpeed = 600.0
var speed = baseSpeed
var direction = 1
var pinStopped = false
var level = 1
var maxLevel = 3
var in_zone = false
var success = false


func _ready():
		NextButton.visible = false
func _physics_process(delta):
		animation.play("jigglejiggle")
		if Input.is_action_pressed("ui_accept") and not pinStopped:
			pinStopped = true
		Pin.position.x+= direction * speed * delta
		if Pin.position.x <= -300 or Pin.position.x >= 200:
			direction*=-1
		if pinStopped and in_zone:
			ResultLabel.text = "Success"
			direction*= 0
			NextButton.visible = true
			NextButton.text = "Leave"
			success = true
		if pinStopped and not in_zone:
			ResultLabel.text = "Fail"
			direction*=0
			NextButton.visible = true
			NextButton.text = "Leave"
			success = false
		

func _on_redzone_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
	in_zone = true
	
	
func _on_redzone_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
	in_zone = false
	
	
func _on_next_button_pressed() -> void:
	if success:
		get_tree().change_scene_to_file("res://secret_room_scene/secret_room.tscn") #change to next scene or smt I guess
	if not success:
		get_tree().change_scene_to_file("res://secret_room_scene/secret_room.tscn")
