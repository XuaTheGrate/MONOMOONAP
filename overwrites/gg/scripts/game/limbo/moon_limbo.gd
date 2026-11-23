extends "res://gg/scripts/game/limbo/moon_limbo.gd"


func _entered_limbo() -> void :
	await super()
	ModLoaderLog.debug("Detected entering Moon Limbo", ArchipelagoMod.LOG_NAME)
	if GameState.DoorType.KING_MARKER not in GameState.open_doors and _was_in_limbo:
		ModLoaderLog.debug("Detected Moon Fixed", ArchipelagoMod.LOG_NAME)
		ArchipelagoMod.instance.manager.ap_goal_reached.emit(ArchipelagoManager.Goal.FIX_MOON)

func _on_reached_ghost() -> void:
	# This is the "Fix Moon Reward" location, don't send if the goal is Fix Moon
	if ArchipelagoMod.instance.manager.goal != ArchipelagoManager.Goal.FIX_MOON:
		ArchipelagoMod.instance.ap_location_collected.emit(7003)
	
	# Setting KING_MARKER was done when receiving the crown emblem, which stops
	# the player from reaching Fix Moon. So we call it here instead.
	GG.append_if_unique(GameState.open_doors, GameState.DoorType.KING_MARKER)

	await super()
