extends "res://gg/scripts/game/objects/trophies_statue.gd"

func _ready() -> void:
	GameSignals.collectable_collected.connect(_on_collectable_collected)
	super()



func _on_break_animation_finished() -> void:
	ArchipelagoMod.instance.manager.ap_goal_reached.emit(ArchipelagoManager.Goal.FULL_MOON)
	await super()

func _on_collectable_collected(collectable: Collectable) -> void: 
	if collectable is CollectableTrophy:
		collected_trophies[collectable.id].visible = true
