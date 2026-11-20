@tool
class_name AncientConversationOverride
extends "res://gg/scripts/game/conversation/ancient_conversation.gd"

func start(ancient: GameGlobals.AncientType) -> void:
	ModLoaderLog.debug("Starting ancient conversation with %s" % ancient, ArchipelagoMod.LOG_NAME)
	GameGlobals.in_conversation = true
	GG.safe_connect(GameSignals.debug_skip, _on_debug_skip)
	var fragment_type: Collectable.Type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	match ancient:
		GameGlobals.AncientType.FISH:
			ancient_sprite.texture = fish_texture
			moon_fragment_sprite.texture = ArchipelagoMod.instance.manager.get_ancient_override_sprite(6002)
		GameGlobals.AncientType.OWL:
			ancient_sprite.texture = owl_texture
			moon_fragment_sprite.texture = ArchipelagoMod.instance.manager.get_ancient_override_sprite(6000)
		GameGlobals.AncientType.RABBIT:
			ancient_sprite.texture = rabbit_texture
			moon_fragment_sprite.texture = ArchipelagoMod.instance.manager.get_ancient_override_sprite(6001)
		GameGlobals.AncientType.WOLF:
			ancient_sprite.texture = wolf_texture
			moon_fragment_sprite.texture = ArchipelagoMod.instance.manager.get_ancient_override_sprite(6003)
	allow_to_continue = false
	animation_player.play(&"show")
	animation_player.advance(0.0)
	ModLoaderLog.debug("Playing show animation", ArchipelagoMod.LOG_NAME)
	await animation_player.animation_finished
	GameSignals.conversation_started.emit()
	if fragment_type not in GameState.items:
		GameState.items.append(fragment_type)
	animation_player.play(&"hide")
	ModLoaderLog.debug("Play hide animation, await beam_created", ArchipelagoMod.LOG_NAME)
	await GameSignals.beam_created
	ModLoaderLog.debug("Beam created, queueing free", ArchipelagoMod.LOG_NAME)
	queue_free()
	GameState.items.erase(fragment_type)
	var temp_collectable: Collectable = Collectable.new()
	temp_collectable.type = fragment_type
	temp_collectable.icon = moon_fragment_sprite.texture
	GameSignals.collectable_collected.emit(temp_collectable)
	ModLoaderLog.debug("Emitted new collectable", ArchipelagoMod.LOG_NAME)
	temp_collectable.queue_free()
