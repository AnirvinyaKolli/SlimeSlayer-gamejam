extends Node

const MAX_HEALTH = 1000
var current_health = MAX_HEALTH
var is_invulnerable = false
var damage_cooldown = 0.3


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
	start_invulnerability()

func start_invulnerability() -> void:
	is_invulnerable = true
	invuln_timer.start()

func _on_invuln_timer_timeout() -> void:
	is_invulnerable = false
