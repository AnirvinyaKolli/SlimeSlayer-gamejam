extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000.0
const MAX_FALL_SPEED = 700.0
const DASH_SPEED = 800.0

enum AnimState { IDLE, RUN, JUMP, FALL, ATTACK, DASH }

const Attacks = ["attack", "attack2"]
var current_attack = 0; 

var anim_state = AnimState.IDLE
var is_attacking = false
var can_dash = true
var damage = 20
var direction

@onready var hurt_box: Area2D = $hurt_box
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var dash_timer: Timer = $dash_timer
@onready var hit_box: Area2D = $hit_box
@onready var attack_timer: Timer = $attack_timer
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	attack_timer.wait_time = sprite.sprite_frames.get_frame_count(Attacks[current_attack]) / sprite.sprite_frames.get_animation_speed(Attacks[current_attack])
	dash_timer.wait_time = sprite.sprite_frames.get_frame_count("dash") / sprite.sprite_frames.get_animation_speed("dash")
	hit_box.monitoring = false
	hit_box.set_collision_layer_value(1, false)
	call_deferred("define_global")
	
func define_global():
	PlayerCombatVars.set_player_node(self)

func _physics_process(delta):
	if not is_on_floor() and anim_state != AnimState.DASH:
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	elif velocity.y > 0:
		velocity.y = 0.0

	if Input.is_action_just_pressed("ATTACK") and not is_attacking:
		start_attack()
	if Input.is_action_just_pressed("DASH") and  can_dash:
		start_dash()
		
	if anim_state != AnimState.DASH :
		direction = Input.get_action_strength("RIGHT") - Input.get_action_strength("LEFT")
		velocity.x = direction * SPEED

		if Input.is_action_just_pressed("JUMP") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if direction != 0:
			sprite.flip_h = direction > 0

		update_anim_state(velocity, direction)
	if sprite.flip_h:
		hit_box.position.x = abs(hit_box.position.x) 
		hit_box.rotation = deg_to_rad(180)
	else:
		hit_box.position.x = abs(hit_box.position.x) * -1
		hit_box.rotation = deg_to_rad(0)


	self.velocity = velocity
	PlayerCombatVars.set_position(global_position)
	move_and_slide()

func start_attack():
	velocity.x = 0
	is_attacking = true
	attack_timer.start()
	hit_box.monitoring = true
	hit_box.set_collision_layer_value(1, true) 
	change_anim_state(AnimState.ATTACK)

func start_dash():
	if sprite.flip_h:
		velocity.x += DASH_SPEED
	else:
		velocity.x -= DASH_SPEED

	hurt_box.monitoring = false
	hurt_box.set_collision_layer_value(1, false)
	can_dash = false
	dash_timer.start()
	hit_box.monitoring = true
	hit_box.set_collision_layer_value(1, true) 
	change_anim_state(AnimState.DASH)

func update_anim_state(velocity: Vector2, direction: float) -> void:
	if anim_state != AnimState.ATTACK and anim_state != AnimState.DASH:
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
			sprite.play(Attacks[current_attack])
			if current_attack == 0:
				current_attack = 1
			else:
				current_attack = 0 
		AnimState.DASH:
			sprite.play("dash")


func _on_attack_timer_timeout() -> void:
	is_attacking = false
	hit_box.monitoring = false
	hit_box.set_collision_layer_value(1, false)
	change_anim_state(AnimState.IDLE)
	attack_timer.wait_time = sprite.sprite_frames.get_frame_count(Attacks[current_attack]) / sprite.sprite_frames.get_animation_speed(Attacks[current_attack])



func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("boss_hit_box"):
		PlayerCombatVars.take_damage(10)


func _on_dash_timer_timeout() -> void:
	dash_cooldown.start()
	hit_box.monitoring = false
	hit_box.set_collision_layer_value(1, false)
	change_anim_state(AnimState.IDLE)
	hurt_box.monitoring = true
	hurt_box.set_collision_layer_value(1, true) 


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
