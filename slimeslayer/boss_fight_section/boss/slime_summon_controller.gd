extends CharacterBody2D

@onready var hurt_box: Area2D = $Area2D

const GRAVITY = 1500
const DAMAGE = 50
const HOP_TRIGGER_DISTANCE = 100
const HOP_DURATION = 0.5
const KNOCKBACK_DECAY = 50.0

enum State { RUNNING, HOP, KNOCKBACK }
var state = State.RUNNING

var speed = 100.0
var target_dir = -1
var hop_vector = Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_state(delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if state != State.KNOCKBACK:
			velocity.y = 0

func change_state(new_state: State) -> void:
	state = new_state

func handle_state(delta: float) -> void:
	if PlayerCombatVars.player == null:
		return

	var player_pos = PlayerCombatVars.player.global_position
	var dist = player_pos.x - position.x
	target_dir = sign(dist)

	match state:
		State.RUNNING:
			velocity.x = speed * target_dir

			if abs(dist) < HOP_TRIGGER_DISTANCE and is_on_floor():
				hop_vector = calculate_hop(player_pos)
				change_state(State.HOP)

		State.HOP:
			if velocity != hop_vector:
				velocity = hop_vector

			if is_on_floor():
				change_state(State.RUNNING)

		State.KNOCKBACK:
			if is_on_floor():
				change_state(State.RUNNING)

func calculate_hop(target_pos: Vector2) -> Vector2:
	var dx = target_pos.x - position.x
	var time = HOP_DURATION
	var vx = dx / time
	var vy = -(0.5 * GRAVITY * time)
	return Vector2(vx, vy)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hit_box"):
		var knockback = Vector2.ZERO
		var knockback_x_factor = randf_range(800, 1200)
		var knockback_y_factor = randf_range(400, 600)

		var player_vel = PlayerCombatVars.player.velocity
		
		if PlayerCombatVars.player.sprite.flip_h:
			knockback.x = player_vel.x + knockback_x_factor 
		else:
			knockback.x = (abs(player_vel.x) + knockback_x_factor ) * -1

		if player_vel.y < 0:
			knockback.y = player_vel.y + knockback_y_factor
		else:
			knockback.y = -knockback_y_factor

		velocity = knockback
		change_state(State.KNOCKBACK)
