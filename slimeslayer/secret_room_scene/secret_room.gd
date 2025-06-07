extends Control

@onready var redzone = $Button

func _ready():
	pass
		
func _physics_process(delta):
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://lock_picking_scene/lock_picking.tscn")
