extends CharacterBody2D

@onready var hurt_box: Area2D = $Area2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

const GRAVITY = 1500
const DAMAGE = 50
const HOP_TRIGGER_DISTANCE = 100
const HOP_DURATION = 0.5
const KNOCKBACK_DECAY = 50.0
var health = 200 

enum State { RUNNING, HOP, KNOCKBACK }
var state = State.RUNNING

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var speed = 100.0
var target_dir = -1
var hop_vector = Vector2.ZERO


var flash_time := 0.1
var flash_color := Color(1, 0, 0) 

func flash_red():
	sprite_2d.modulate = flash_color
	await get_tree().create_timer(flash_time).timeout
	sprite_2d.modulate = Color(1, 1, 1)

func _ready() -> void:
	sprite_2d.play("default")

func _physics_process(delta: float) -> void:
	if health < 0: 
		queue_free()
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
	if target_dir < 0:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false
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
		audio.play()
		flash_red()
		health -= 50
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
