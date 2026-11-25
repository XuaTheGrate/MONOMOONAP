@tool
extends "res://gg/scripts/game/objects/telescope.gd"

var show_beams_ap: bool:
	get():
		var moon_pieces_required: int = constellation_id # 1,2,3,4
		return ArchipelagoMod.instance.manager.have_moon_pieces(moon_pieces_required)\
		and GameState.DoorType.SKY_MOON not in GameState.open_doors

func _on_entered_new_room(index: Vector2i) -> void :
	var should_show_beams: bool = index != GameGlobals.sky_moon_room\
	and index != room_index\
	and index.y >= room_index.y\
	and show_beams_ap
	
	for beam: Line2D in beams:
		beam.visible = should_show_beams
	if room_index != index:
		GG.set_disabled_and_hide(self)
		return
	GG.set_enabled_and_show(self)
	if EndRoom.did_slot_moon:
		for i: int in range(4):
			beam_start_point_bg.material.set_shader_parameter(&"has_line" + str(i + 1), false)
