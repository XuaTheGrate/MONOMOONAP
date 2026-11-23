extends "res://gg/scripts/game/dragons/earth_dragon.gd"

func _on_healed() -> void :
	GG.logt(GG.LogTag.Gameplay, "Dragon healed", element)
	GameSignals.helped_dragon.emit(element)
	ScreenFader.set_hidden(Color.WHITE)
	animation_player.play(&"after_moon")
	if player_position_after_fade:
		GameGlobals.player.global_position = player_position_after_fade.global_position
	if moon_position_after_fade:
		GameGlobals.moon.lock_to = moon_position_after_fade.global_position
	GameState.special_save_event = GameState.dragon_2_special_save_event(element)
	await get_tree().create_timer(delay_between_popup_hide_and_fade_in, false).timeout
	GameSignals.request_save_game.emit()
	ScreenFader.show_game()
	GG.logt(GG.LogTag.Gameplay, "Heal Dragon", GameGlobals.Element.find_key(element))
	await ScreenFader.game_shown
	GameGlobals.moon.lock_to = Vector2.ZERO
	GameGlobals.moon.force_locked = false
	GameGlobals.player.disable_gravity_until_ms = 0
	GameGlobals.player._play_animation(&"idle")
	await get_tree().create_timer(delay_before_book, false).timeout

	GameGlobals.player.enable_input = true
	#GameGlobals.inventory.book.mesh_book._current_index = -1
	#GameGlobals.inventory.last_item = Collectable.Type.BOOK
	GameGlobals.inventory.allow_to_open = true
	#GameGlobals.inventory.show_inventory()
	await get_tree().create_timer(delay_before_achievement, false).timeout
	AchievementsManager.unlock(heal_achievement)
