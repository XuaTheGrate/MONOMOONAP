extends "res://gg/scripts/game/limbo/true_ending_limbo.gd"


func _entered_limbo() -> void :
	await super()
	if not _was_in_limbo: return # taken from super, some sort of guard
	ArchipelagoMod.instance.manager.ap_goal_reached.emit(ArchipelagoManager.Goal.THE_END)
