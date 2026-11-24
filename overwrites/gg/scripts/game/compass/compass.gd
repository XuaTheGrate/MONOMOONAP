extends "res://gg/scripts/game/compass/compass.gd"


func _reveal_orb(id: int) -> void :
	var collected_so_far: int = GameState.orbs.size()
	var orb: CompassOrbSlot = get_orb(id)
	if not orb: return
	if collected_so_far <= 1:

		ResourceLoader.load_threaded_request(orb_effect_scene)
	elif collected_so_far < orbs.size():

		orb.set_revealed()

		if not _orb_effect:
			var scene: PackedScene = ResourceLoader.load_threaded_get(orb_effect_scene)
			_orb_effect = scene.instantiate()
			GameGlobals.current_region.add_child(_orb_effect)
			if not _orb_effect.is_node_ready():
				await _orb_effect.ready
		_orb_effect.show_effect(id)
		return
	GameGlobals.inventory.allow_to_open = false
	GameGlobals.player.disable_input_for(first_slot_delay_to_show_compass)

	GameGlobals.player.is_picking_up_item = true
	await get_tree().create_timer(first_slot_delay_to_show_compass, false).timeout
	GameGlobals.inventory.allow_to_open = true
	_is_revealing_compass = collected_so_far >= orbs.size()
	GameGlobals.inventory.last_item = Collectable.Type.COMPASS
	if GameGlobals.inventory.visible:
		GameGlobals.inventory._switch_to_tab(Collectable.Type.COMPASS)
	else:
		GameGlobals.inventory.show_inventory()
	GameGlobals.player.is_picking_up_item = false
	GameGlobals.inventory.allow_to_close = false
	if collected_so_far <= 1:
		SoundBus.compass_appear.play()
		animation_player.play(&"appear")
		animation_player.advance(0.0)
		await animation_player.animation_finished
		animation_player.play(&"idle")

	while animation_player.current_animation != &"idle":
		await get_tree().process_frame
	await orb.reveal()
	if not _is_revealing_compass:
		GameGlobals.inventory.allow_to_close = true
		return
	_on_collected_all_orbs()
