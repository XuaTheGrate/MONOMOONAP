class_name CollectableAP
extends Collectable

const SCENE_AP: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")
const SCENE_MAP: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_map.tscn")
const SCENE_CONCH: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_conch.tscn")
const SCENE_LYRE: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_instrument.tscn")
const SCENE_MARKERS: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_markers.tscn")
const SCENE_PAGE: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_page.tscn")
const SCENE_ORB: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_orb.tscn")
const SCENE_GOLDEN_QUILL: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_golden_quill.tscn")
const SCENE_RELIC: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_trophy.tscn")
const SCENE_MOON_FRAGMENT: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectible_moon_fragment.tscn")

var location_id: int

static func create_new(location: int, item_id: int) -> CollectableAP:
	var s: CollectableAP
	
	match item_id:
		-1: s = SCENE_AP.instantiate()
		1000: s = SCENE_MAP.instantiate()
		1001: s = SCENE_CONCH.instantiate()
		1002: s = SCENE_LYRE.instantiate()
		1003: s = SCENE_MARKERS.instantiate()
		_:
			match item_id / 1000:
				2: s = SCENE_PAGE.instantiate()
				3:
					s = SCENE_ORB.instantiate()
					s._set_orb_data(item_id / 100)
				4: s = SCENE_GOLDEN_QUILL.instantiate()
				5:
					s = SCENE_RELIC.instantiate()
					s._set_relic_data(item_id)
				6:
					s = SCENE_MOON_FRAGMENT.instantiate()
					s._set_moon_fragment()
				7:
					# TODO: emblems
					s = SCENE_AP.instantiate()
	
	s.location_id = location
	return s

func _on_ap_item_received(item: int) -> void:
	if item / 1000 != 6: return
	icon = CollectableMoonFragment.sprites[ArchipelagoManager.get_next_fragment()]
	$Squasher/Sprite.texture = icon
	$Squasher/Sprite/SelectedOutline.texture = icon

func _set_moon_fragment() -> void:
	ArchipelagoMod.instance.ap_item_received.connect(_on_ap_item_received)
	icon = CollectableMoonFragment.sprites[ArchipelagoManager.get_next_fragment()]
	$Squasher/Sprite.texture = icon
	$Squasher/Sprite/SelectedOutline.texture = icon

func _set_relic_data(id: int) -> void:
	match id:
		5000: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_skull.tres")
		5001: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_amulet.tres")
		5002: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_fruit.tres")
		5003: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_mirror.tres")
		5004: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_hourglass.tres")
		5005: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_wand.tres")
		5006: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_scales.tres")
		5007: icon = preload("res://gg/textures/game/collectables/secret-collectables/relic_crown.tres")
	$Squasher/Sprite.texture = icon
	$Squasher/Sprite/SelectedOutline.texture = icon

func _set_orb_data(id: int) -> void:
	match id:
		30: 
			icon = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/blue_orb.tres")
			$Squasher/Sprite.frame = 0
		31:
			icon = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/green_orb.tres")
			$Squasher/Sprite.frame = 2
		32:
			icon = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/red_orb.tres")
			$Squasher/Sprite.frame = 3
		33:
			icon = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/yellow_orb.tres")
			$Squasher/Sprite.frame = 1

func _ready() -> void:
	type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	super()

func set_collected() -> void:
	super()
	ModLoaderLog.info("set_collected AP item %d" % location_id, ArchipelagoMod.LOG_NAME)

func spawn_collected_effect() -> Node2D:
	var node: Node2D = super()
	if node != null:
		node.get_node("CollectableOrb").texture = sprite.texture
	return node
