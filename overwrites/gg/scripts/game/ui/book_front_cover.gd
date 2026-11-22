class_name BookFrontCoverOverwrite
extends "res://gg/scripts/game/ui/book_front_cover.gd"

func _ready() -> void:
	ArchipelagoMod.instance.ap_item_received.connect(_on_ap_item_received)
	
	await super()
	
	_reset_marker(water_book_marker, "Sea Emblem")
	_reset_marker(earth_book_marker, "Earth Emblem")
	_reset_marker(sky_book_marker, "Sky Emblem")
	_reset_marker(moon_book_marker, "Crown Emblem")
	
	if moon_book_marker.is_unlocked:
		# This makes the little moon in the centre of the book cover turn into the crown shaped slot
		animation_player.play(&"revealed")
	else:
		# This makes it go away if got revealed by super()
		animation_player.play(&"RESET")
	
func _reset_marker(marker:BookMarker, ap_item_name: String) -> void:
	marker.is_unlocked = ArchipelagoMod.instance.manager.have_item(ap_item_name)
	if marker.is_unlocked:
		GG.set_enabled_and_show(marker)
	else:
		GG.set_disabled_and_hide(marker)


func try_unlock_markers() -> bool:
	if not water_book_marker.is_unlocked and GameGlobals.Element.WATER in GameState.helped_dragons:
		check_ap_location(MarkersStack.Type.WATER)
		return false
	if not earth_book_marker.is_unlocked and GameGlobals.Element.EARTH in GameState.helped_dragons:
		check_ap_location(MarkersStack.Type.EARTH)
		return false
	if not sky_book_marker.is_unlocked and GameGlobals.Element.SKY in GameState.helped_dragons:
		check_ap_location(MarkersStack.Type.SKY)
		return false
	if not moon_book_marker.is_unlocked\
	and GameState.DoorType.SKY_MOON in GameState.open_doors\
	and GameGlobals.room_index == GameGlobals.sky_moon_room:
		check_ap_location(MarkersStack.Type.KING)
		GG.append_if_unique(GameState.open_doors, GameState.DoorType.KING_MARKER)
		return false
	return false
	
func check_ap_location(type:MarkersStack.Type) -> void:
	match type:
		MarkersStack.Type.EARTH:
			ArchipelagoMod.instance.ap_location_collected.emit(7000)
		MarkersStack.Type.WATER:
			ArchipelagoMod.instance.ap_location_collected.emit(7001)
		MarkersStack.Type.SKY:
			ArchipelagoMod.instance.ap_location_collected.emit(7002)
		MarkersStack.Type.KING:
			ArchipelagoMod.instance.ap_location_collected.emit(7003)
		
func _on_ap_item_received(item:int) -> void:
	match item:
		7000:
			unlock_marker(MarkersStack.Type.EARTH)
		7001:
			unlock_marker(MarkersStack.Type.WATER)
		7002:
			unlock_marker(MarkersStack.Type.SKY)
		7003:
			unlock_marker(MarkersStack.Type.KING)

func unlock_marker(type_id: MarkersStack.Type) -> void :
	match type_id:
		MarkersStack.Type.WATER:
			water_book_marker.unlock()
			await water_book_marker.animation_player.animation_finished
			marker_unlocked.emit()
		MarkersStack.Type.EARTH:
			earth_book_marker.unlock()
			await earth_book_marker.animation_player.animation_finished
			marker_unlocked.emit()
		MarkersStack.Type.SKY:
			sky_book_marker.unlock()
			await sky_book_marker.animation_player.animation_finished
			marker_unlocked.emit()
		MarkersStack.Type.KING:
			SoundBus.king_marker_reveal.play()
			animation_player.play(&"reveal")
			await animation_player.animation_finished
			GG.set_enabled_and_show(moon_book_marker)
			animation_player.play(&"revealed")
			moon_book_marker.is_unlocked = true
			#GG.append_if_unique(GameState.open_doors, GameState.DoorType.KING_MARKER)
			marker_unlocked.emit()
