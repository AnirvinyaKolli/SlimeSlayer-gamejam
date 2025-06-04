extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000.0
const MAX_FALL_SPEED = 700.0

enum AnimState { IDLE, RUN, JUMP, FALL, ATTACK }
var anim_state = AnimState.IDLE
var is_attacking = false
var damage = 20
var direction

@onready var hit_box: Area2D = $hit_box
@onready var attack_timer: Timer = $attack_timer
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	attack_timer.wait_time = sprite.sprite_frames.get_frame_count("attack") / sprite.sprite_frames.get_animation_speed("attack")
	hit_box.monitoring = false
	hit_box.set_collision_layer_value(1, false)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	elif velocity.y > 0:
		velocity.y = 0.0

	if Input.is_action_just_pressed("ATTACK") and not is_attacking:
		start_attack()

	else:
		direction = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
		velocity.x = direction * SPEED

		if Input.is_action_just_pressed("JUMP") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if direction != 0:
			sprite.flip_h = direction > 0

		update_anim_state(velocity, direction)

	self.velocity = velocity
	PlayerCombatVars.set_position(global_position)
	move_and_slide()

func start_attack():
	is_attacking = true
	attack_timer.start()
	hit_box.monitoring = true
	hit_box.set_collision_layer_value(1, true) 
	change_anim_state(AnimState.ATTACK)

func update_anim_state(velocity: Vector2, direction: float) -> void:
	if anim_state != AnimState.ATTACK:
		if not is_on_floor():
			if velocity.y < 0:
				change_anim_state(AnimState.JUMP)
			else:
				change_anim_state(AnimState.FALL)
		elif direction != 0:
			change_anim_state(AnimState.RUN)
		else:
			change_anim_state(AnimState.IDLE)

func change_anim_state(new_state: int) -> void:
	if anim_state == new_state:
		return

	anim_state = new_state

	match anim_state:
		AnimState.IDLE:
			sprite.play("idle")
		AnimState.RUN:
			sprite.play("run")
		AnimState.JUMP:
			sprite.play("jump")
		AnimState.FALL:
			sprite.play("fall")
		AnimState.ATTACK:
			sprite.play("attack")


func _on_attack_timer_timeout() -> void:
	is_attacking = false
	hit_box.monitoring = false
	hit_box.set_collision_layer_value(1, false)
	change_anim_state(AnimState.IDLE)


func _on_hit_box_area_entered(area: Area2D) -> void:
	var dir = -1
	if sprite.flip_h:
		dir = 1
	
	if area.is_in_group("boss_hurt_box"):
		BossVars.take_damage(damage, Vector2(800 * dir, -300))
		BossFightSignalManager.emit_signal("boss_hit")
