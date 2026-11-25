@tool
extends "res://gg/scripts/game/dragons/end_room.gd"


func _on_entered_new_room(index: Vector2i) -> void :
	if room_index != index:
		if GameSignals.locked_moon_fragments.is_connected(_on_locked_moon_fragments):
			GameSignals.locked_moon_fragments.disconnect(_on_locked_moon_fragments)
			GameSignals.moon_fragment_locked.disconnect(_on_moon_fragment_locked)
		GG.set_disabled_and_hide(self)
		return
	if full_moon_door in GameState.open_doors:
		GG.set_enabled_and_show(self)
		return
	moon_slot_bg.visible = ArchipelagoMod.instance.manager.have_moon_pieces(1)
	var completed: int = 0
	for i: int in range(beam_ids.size()):
		var id: int = beam_ids[i]
		if ArchipelagoMod.instance.manager.have_moon_pieces(id) and not did_slot_moon:
			completed += 1
			slot_material.set_shader_parameter(&"has_line" + str(i + 1), true)
		else:
			slot_material.set_shader_parameter(&"has_line" + str(i + 1), false)
		slot_material.set_shader_parameter(&"circle_scale", circle_scales[completed - 1])
	slot_material.set_shader_parameter(&"slot_frame", completed - 1)
	# @@ TEMP:
	if completed >= 4 and not GameSignals.locked_moon_fragments.is_connected(_on_locked_moon_fragments):
		GameSignals.locked_moon_fragments.connect(_on_locked_moon_fragments)
		GameSignals.moon_fragment_locked.connect(_on_moon_fragment_locked)
	GG.set_enabled_and_show(self)
