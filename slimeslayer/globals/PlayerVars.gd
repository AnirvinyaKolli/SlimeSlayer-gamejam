extends Node
const MAX_HEALTH = 200
var current_player_health = MAX_HEALTH

func take_damage(dmg):
	current_player_health -= dmg
