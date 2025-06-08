extends Control
@onready var bossbar: TextureProgressBar = $bossbar
@onready var health_bar: TextureProgressBar = $health_bar

func _ready() -> void:
	bossbar.max_value = BossVars.MAX_HEALTH
	bossbar.value = BossVars.current_health
	health_bar.max_value = PlayerCombatVars.MAX_HEALTH
	health_bar.value = PlayerCombatVars.current_health
func _process(delta: float) -> void:
	bossbar.value = BossVars.current_health
	health_bar.value = PlayerCombatVars.current_health
