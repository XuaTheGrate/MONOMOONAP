extends "res://gg/scripts/game/ui/inventory.gd"

func _on_collectable_collected(collectable: Collectable) -> void:
	ModLoaderLog.debug("Received %s %d" % [collectable.name, collectable.type], ArchipelagoMod.LOG_NAME)
	if collectable.type == ArchipelagoMod.AP_COLLECTABLE_TYPE:
		GameGlobals.player.enable_input = true
		GameGlobals.player._play_animation(&"idle")
		return
	super(collectable)
