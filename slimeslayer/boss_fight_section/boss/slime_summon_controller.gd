extends CharacterBody2D


const GRAVITY = 1500
const DAMAGE = 50

enum State { RUNNING, HOP}
var state = State.RUNNING

var speed = 3 
var target_dir = -1
var was_on_floor = false

var height = 0.0
var distance = 0.0

func _ready() -> void:
	BossFightSignalManager.boss_hit.connect(Callable(self, "contacted"))
		
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_state(delta)
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func change_state(new_state):
	state = new_state 
	
func handle_state(delta):
	print(velocity)
	match state:
		State.RUNNING: 
			if abs(PlayerCombatVars.position.x - position.x) < 100:
				hop(get_jump(abs(PlayerCombatVars.position.x - position.x)))
				change_state(State.HOP)
			if PlayerCombatVars.position.x - position.x > 0:
				target_dir = 1
			else:
				target_dir =-1
				
			if is_on_floor():
				velocity.x += speed*target_dir
				
		State.HOP:
			pass
func get_jump(d):
	return Vector2(d/100, 0.5*GRAVITY*100)
func hop(hop_vector):
	velocity += hop_vector

func contacted():
	velocity += BossVars.knockback
