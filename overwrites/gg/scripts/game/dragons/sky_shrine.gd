extends "res://gg/scripts/game/dragons/sky_shrine.gd"

var trophy_override: CollectableAP

func _ready() -> void:
	super()
	if not GameState.is_constellation_solved(king_constellation.id):
		ModLoaderLog.debug("Hiding trophy override %s" % trophy_override, ArchipelagoMod.LOG_NAME)
		GG.set_disabled_and_hide(trophy_override)
		trophy_override.can_be_collected = false

func _on_king_constellation_solved() -> void:
	super()
	GG.set_enabled_and_show(trophy_override)
	trophy_override.can_be_collected = true

# this felt too complicated to override with the super method
func _continue_to_cue_dragons(room_index: Vector2i) -> void :
	GameGlobals.inventory.allow_to_open = false
	while not GameGlobals.player._was_on_floor:
		await get_tree().process_frame
	if room_index != _window_room_index:
		_waiting_to_cue_dragons = true
		GG.safe_connect(GameSignals.entered_new_room, _on_entered_new_room)
		return
	var to_center: float = trophy_override.global_position.x - GameGlobals.player.global_position.x
	if abs(to_center) > _walk_to_position_offset:
		var pos: Vector2 = trophy_override.global_position
		pos.x -= signf(to_center) * _walk_to_position_offset
		pos.y = GameGlobals.player.global_position.y
		GameGlobals.player.walk_to_position = pos
		var was_aborted: bool = await GameGlobals.player.walk_to_position_reached
		if was_aborted:
			await GameSignals.player_teleported
			_continue_to_cue_dragons(GameGlobals.room_index)
			return
	dragons_loop.cue_dragons()
	await get_tree().create_timer(delay_between_dragons_and_constellation, false).timeout
	GameGlobals.inventory.allow_to_open = true
	king_constellation._dim()
	activate_constellation()
