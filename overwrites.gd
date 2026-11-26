extends Node

func _init() -> void:
	var r: Resource = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scenes/meta/main_menu.tscn")
	r.take_over_path("res://gg/scenes/meta/main_menu.tscn")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/ui/meta/main_menu.gd")
	r.take_over_path("res://gg/scripts/game/ui/meta/main_menu.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/conversation/ancient_conversation.gd")
	r.take_over_path("res://gg/scripts/game/conversation/ancient_conversation.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/ui/inventory.gd")
	r.take_over_path("res://gg/scripts/game/ui/inventory.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/limbo/moon_limbo.gd")
	r.take_over_path("res://gg/scripts/game/limbo/moon_limbo.gd")
				 
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/ui/book_front_cover.gd")
	r.take_over_path("res://gg/scripts/game/ui/book_front_cover.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/dragons/earth_dragon.gd")
	r.take_over_path("res://gg/scripts/game/dragons/earth_dragon.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/dragons/sky_dragon.gd")
	r.take_over_path("res://gg/scripts/game/dragons/sky_dragon.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/dragons/water_dragon.gd")
	r.take_over_path("res://gg/scripts/game/dragons/water_dragon.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/limbo/true_ending_limbo.gd")
	r.take_over_path("res://gg/scripts/game/limbo/true_ending_limbo.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/objects/trophies_statue.gd")
	r.take_over_path("res://gg/scripts/game/objects/trophies_statue.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/camera/remote_camera.gd")
	r.take_over_path("res://gg/scripts/game/camera/remote_camera.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/map/map.gd")
	r.take_over_path("res://gg/scripts/game/map/map.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/compass/compass.gd")
	r.take_over_path("res://gg/scripts/game/compass/compass.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/objects/telescope.gd")
	r.take_over_path("res://gg/scripts/game/objects/telescope.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/dragons/end_room.gd")
	r.take_over_path("res://gg/scripts/game/dragons/end_room.gd")

	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/objects/replace_skull_with_trophy.gd")
	r.take_over_path("res://gg/scripts/game/objects/replace_skull_with_trophy.gd")
	
	r = preload("res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/objects/relic_slot_machine.gd")
	r.take_over_path("res://gg/scripts/game/objects/relic_slot_machine.gd")
	
