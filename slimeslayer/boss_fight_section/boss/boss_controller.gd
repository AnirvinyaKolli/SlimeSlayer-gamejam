extends CharacterBody2D

const GRAVITY = 1500

const HOP_HEIGHT = -700 
const HOP_DISTANCE = 500

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG"):
		hop(get_direction())
		
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
	return [-1, 1].pick_random()
	
