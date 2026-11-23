extends "res://gg/scripts/game/objects/trophies_statue.gd"

func _on_break_animation_finished() -> void:
	ArchipelagoMod.instance.manager.ap_goal_reached.emit(ArchipelagoManager.Goal.FULL_MOON)
	await super()
