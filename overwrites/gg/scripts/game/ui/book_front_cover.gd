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
	var to_unlock: Array[MarkersStack.Type] = []
	if not water_book_marker.is_unlocked and ArchipelagoMod.instance.manager.have_item("Sea Emblem"):
		to_unlock.append(MarkersStack.Type.WATER)
	if not earth_book_marker.is_unlocked and ArchipelagoMod.instance.manager.have_item("Earth Emblem"):
		to_unlock.append(MarkersStack.Type.EARTH)
	if not sky_book_marker.is_unlocked and ArchipelagoMod.instance.manager.have_item("Sky Emblem"):
		to_unlock.append(MarkersStack.Type.SKY)
	if not moon_book_marker.is_unlocked and ArchipelagoMod.instance.manager.have_item("Crown Emblem"):
		to_unlock.append(MarkersStack.Type.KING)
	
	for marker: MarkersStack.Type in to_unlock:
		unlock_marker(marker)
	if to_unlock:
		return true
	return false


func _on_ap_item_received(item: APWSClasses.NetworkItem) -> void:
	if item.item / 1000 == 7:
		if GameGlobals.inventory.allow_to_open:
			GameGlobals.inventory.book.mesh_book._current_index = -1
			GameGlobals.inventory.last_item = Collectable.Type.BOOK
			GameGlobals.inventory.show_inventory()
			# Opening the book will lead to calling try_unlock_markers
		

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
