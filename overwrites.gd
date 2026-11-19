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
