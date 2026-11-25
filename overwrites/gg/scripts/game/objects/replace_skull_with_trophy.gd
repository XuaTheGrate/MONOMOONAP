extends "res://gg/scripts/game/objects/replace_skull_with_trophy.gd"


func _ready() -> void:
	if GameGlobals.loading_state < GameSignals.LoadingState.LOADING_COMPLETE:
		await GameSignals.loading_complete
	var skull_trophy_replacement: CollectableAP = get_node('CollectableTrophy')
	if skull_trophy_replacement:
		GG.set_disabled_and_hide(skull_trophy_replacement)
		skull_trophy_replacement.can_be_collected = false
	else:
		reaper.queue_free()
		queue_free()

func _replace_skull_with_trophy(body: Node2D) -> void :
	var skull_trophy_replacement: CollectableAP = get_node('CollectableTrophy')
	if is_instance_valid(skull_trophy_replacement):
		skull_trophy_replacement.global_position = body.global_position
		GG.set_enabled_and_show(skull_trophy_replacement)
		skull_trophy_replacement.can_be_collected = true
		skull_trophy_replacement.reparent(get_parent())
		GameSignals.skull_trophy_spawned.emit()
	GG.set_disabled_and_hide(body)
	queue_free()
