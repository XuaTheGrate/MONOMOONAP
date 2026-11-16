extends Node

var _overrides: Dictionary[String, String] = {
	"res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scenes/meta/main_menu.tscn": "res://gg/scenes/meta/main_menu.tscn",
	"res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/ui/meta/main_menu.gd": "res://gg/scripts/game/ui/meta/main_menu.gd",
	#"res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scripts/game/objects/collectable.gd": "res://gg/scripts/game/objects/collectable.gd"
	"res://mods-unpacked/MayaXTG-Archipelago/overwrites/gg/scenes/game/outside_level.tscn": "res://gg/scenes/game/outside_level.tscn"
}

func _init() -> void:
	for res: String in _overrides.keys():
		var path: String = _overrides[res]
		var r: Resource = load(res)
		r.take_over_path(path)
