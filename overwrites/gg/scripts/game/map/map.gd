@tool
extends "res://gg/scripts/game/map/map.gd"

var ap_markers: Array[CollectableMarker] = []

var AP_MARKER_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/ap_marker.png")

func paint_ap(collectable: CollectableAP) -> void :
	#NOTE: this could be a scene
	var new_marker: CollectableMarker = CollectableMarker.new()
	new_marker.visibility_layer = 32
	var sprite:Sprite2D = Sprite2D.new()
	sprite.texture = AP_MARKER_SPRITE
	sprite.visibility_layer = 32
	new_marker.add_child(sprite)
	
	#Let's just put this in with the orbs
	orb_marker.get_parent().add_child(new_marker)
	
	new_marker.position = round(collectable.position_for_map / 16.0)
	ap_markers.append(new_marker)
	new_marker.collectable = collectable
	new_marker.visible = _is_marker_room_discovered(collectable.room_index, collectable.is_in_darkness)


func _reveal_markers_for_room(room_index: Vector2i) -> void:
	super(room_index)
	for marker: CollectableMarker in ap_markers:
		if not marker: continue
		if not marker.collectable:
			marker.visible = false
			continue
		
		if marker.collectable.room_index == room_index\
		and ( not marker.collectable.is_in_darkness or not darkness.visible):
			marker.visible = true
