extends "res://gg/scripts/game/limbo/moon_limbo.gd"


func _entered_limbo() -> void :
	await super()
	ModLoaderLog.debug("Detected entering Moon Limbo", ArchipelagoMod.LOG_NAME)
	if GameState.DoorType.KING_MARKER not in GameState.open_doors and _was_in_limbo:
		ModLoaderLog.debug("Detected Moon Fixed", ArchipelagoMod.LOG_NAME)
		ArchipelagoMod.instance.manager.ap_goal_reached.emit(ArchipelagoManager.Goal.FIX_MOON)
