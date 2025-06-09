extends Node

const MAX_HEALTH = 200
var current_health = MAX_HEALTH
var is_invulnerable = false
var damage_cooldown = 0.3
var position = Vector2.ZERO

var player
 
func set_player_node(node):
	player = node

@onready var invuln_timer := Timer.new()

func _ready():
	invuln_timer.one_shot = true
	invuln_timer.wait_time = damage_cooldown
	invuln_timer.timeout.connect(_on_invuln_timer_timeout)
	add_child(invuln_timer)

func take_damage(dmg: int) -> void:
	if is_invulnerable:
		return  # ignore damage
	current_health -= dmg
	if current_health < 0:
		get_tree().change_scene_to_file("res://main_ui.tscn")
	start_invulnerability()

func start_invulnerability() -> void:
	is_invulnerable = true
	invuln_timer.start()

func _on_invuln_timer_timeout() -> void:
	is_invulnerable = false

func set_position(pos: Vector2):
	self.position = pos  
