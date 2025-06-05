extends CharacterBody2D

@onready var hop_timer: Timer = $hop_timer
@onready var wall_check_r: RayCast2D = $wall_check_r
@onready var wall_check_l: RayCast2D = $wall_check_l
@onready var birth_timer: Timer = $birth_timer

const GRAVITY = 1500
const DAMAGE = 50
var birth = false

var child = load("res://boss_fight_section/boss/slime_summon.tscn")

enum State { IDLE, WINDUP, HOP, BIRTH }
var state = State.IDLE

var target_dir = -1
var was_on_floor = false

var height = 0.0
var distance = 0.0

func _ready() -> void:
	wall_check_l.target_position = Vector2.LEFT * height
	wall_check_r.target_position = Vector2.RIGHT * distance
	
	call_deferred("add_globals")

func add_globals():
	BossVars.define_boss_node(self)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	apply_friction(delta)
	handle_state(delta)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 50)

func change_state(new_state):
	state = new_state 
	
func handle_state(delta):
	match state:
		State.IDLE:
			if is_on_floor():
				if birth:
					birth = false
					give_birth()
				change_state(State.WINDUP)
				hop_timer.start()
		State.WINDUP:
			pass
		State.HOP:
			if is_on_floor():
				change_state(State.IDLE)
		State.BIRTH: 
			pass

	if is_on_floor():
		if (target_dir == -1 and not wall_check_l.is_colliding()) or (target_dir == 1 and not wall_check_r.is_colliding()):
			var target_speed = 30 * target_dir
			velocity.x = move_toward(velocity.x, target_speed, 300 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, 600 * delta)
			target_dir *= -1

func set_jump_type():
	var jump_type = randi() % 3
	match jump_type:
		0:
			height = randf_range(-500, -400)
			distance = randf_range(200, 300)
		1:
			height = randf_range(-600, -550)
			distance = randf_range(350, 450)
		2:
			height = randf_range(-900, -800)
			distance = randf_range(200, 300)

func hop(dir):
	var hop_vector = Vector2(dir * distance, height)
	velocity += hop_vector

func get_direction():
	var rand_val = randi() % 10
	if rand_val < 7:
		return target_dir
	elif rand_val < 9:
		return -target_dir
	else:
		return 0

func can_hop(dir) -> bool:
	wall_check_l.target_position = Vector2.LEFT * 400
	wall_check_r.target_position = Vector2.RIGHT * 400
	if dir == -1:
		return not wall_check_l.is_colliding()
	elif dir == 1:
		return not wall_check_r.is_colliding()
	return false

	

func _on_hop_timer_timeout() -> void:
	var dir = get_direction()
	if dir != 0 and can_hop(dir):
		set_jump_type()
		hop(dir)
		change_state(State.HOP)
	else:
		change_state(State.IDLE)


func _on_birth_timer_timeout() -> void:
	birth = true 
	
func give_birth():
	change_state(State.BIRTH)
	var new_child = child.instantiate()
	new_child.position = global_position
	GameManager.test_scene.add_child(new_child)
	birth_timer.start()
	change_state(State.IDLE)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hit_box"):
		
		BossVars.take_damage(PlayerCombatVars.player.damage)
		
		var knockback = Vector2(0, -200)
		var knockback_x_factor = randf_range(400, 500)
		var knockback_y_factor = randf_range(200,300)
		
		if PlayerCombatVars.player.sprite.flip_h:
			knockback.x = PlayerCombatVars.player.velocity.x + knockback_x_factor 
		else:
			knockback.x = (abs( PlayerCombatVars.player.velocity.x) + knockback_x_factor ) * -1

		
		if (PlayerCombatVars.player.velocity.y < 0):
			knockback.y = PlayerCombatVars.player.velocity.y + knockback_y_factor 
		else:
			knockback.y =  -1*knockback_y_factor 

		velocity += knockback 
		hop_timer.stop()
		hop_timer.start()
