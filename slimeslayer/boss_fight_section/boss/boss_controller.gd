extends CharacterBody2D

@onready var hop_timer: Timer = $hop_timer
@onready var wall_check_r: RayCast2D = $wall_check_r
@onready var wall_check_l: RayCast2D = $wall_check_l

var boss_bar = load("res://boss_fight_section/boss/boss_bar.tscn")

const GRAVITY = 1500
const HOP_HEIGHT = -700 
const HOP_DISTANCE = 500

var player_dir = -1

func _ready() -> void:
	wall_check_l.target_position = Vector2.LEFT * HOP_DISTANCE
	wall_check_r.target_position = Vector2.RIGHT * HOP_DISTANCE

	await get_tree().process_frame
	add_boss_bar()

func add_boss_bar():
	if GameManager.ui_screen:
		GameManager.ui_screen.add_child(boss_bar.instantiate())
		

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG"):
		pass
	

	apply_gravity(delta)
	apply_friction()
	move_and_slide()
	

func hop(dir):
	var hop_vector = Vector2(dir * HOP_DISTANCE, HOP_HEIGHT)
	velocity += hop_vector

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func apply_friction():
	if is_on_floor():
		velocity.x = move_toward(velocity.x,0,200)

func get_direction():
	
	if wall_check_l.is_colliding():
		return 1
	if wall_check_r.is_colliding():
		return -1
	
	var weighted_list = []
	for i in range(2):
		weighted_list.append(player_dir)
	for i in range(1):
		weighted_list.append(-1*player_dir)
	return weighted_list.pick_random()
	

func _on_hop_timer_timeout() -> void:
	if is_on_floor():
		hop(get_direction())
