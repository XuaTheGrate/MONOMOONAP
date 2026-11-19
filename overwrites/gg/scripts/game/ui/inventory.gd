extends "res://gg/scripts/game/ui/inventory.gd"

func _on_collectable_collected(collectable: Collectable) -> void:
	if collectable.type == ArchipelagoMod.AP_COLLECTABLE_TYPE:
		# TODO: custom storage for ap locations
		GameGlobals.player.enable_input = true
		GameGlobals.player._play_animation(&"idle")
		return
	super(collectable)
