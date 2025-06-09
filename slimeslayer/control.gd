extends Control
@onready var button: Button = $Button

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Maze.tscn") 
