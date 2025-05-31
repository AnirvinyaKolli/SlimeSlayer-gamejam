extends CharacterBody2D

# Movement constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000.0
const MAX_FALL_SPEED = 700.0

enum AnimState { IDLE, RUN, JUMP, FALL }
var anim_state = AnimState.IDLE

@onready var sprite: AnimatedSprite2D = $Sprite

func _physics_process(delta):
	var velocity = self.velocity

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		velocity.y = 0.0

	var direction = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
	velocity.x = direction * SPEED

	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	self.velocity = velocity
	move_and_slide()

	if direction != 0:
		sprite.flip_h = direction > 0

	update_anim_state(velocity, direction)

func update_anim_state(velocity: Vector2, direction: float) -> void:
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
