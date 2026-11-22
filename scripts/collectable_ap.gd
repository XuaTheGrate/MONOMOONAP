class_name CollectableAP
extends Collectable

const SCENE: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")

var location_id: int

var sprite_override: Texture2D
var sprite_unlit_override: Texture2D
var sprite_normal_override: Texture2D

static func create_new(location: int, item_id: int) -> CollectableAP:
	var s: CollectableAP = SCENE.instantiate()
	s.location_id = location
	s.sprite_override = ArchipelagoMod.instance.manager.get_sprite_override(item_id)
	return s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	icon = sprite_override
	sprite.texture = sprite_override
	selected_outline.texture = sprite_override
	super()

func set_collected() -> void:
	super()
	ModLoaderLog.info("set_collected AP item %d" % location_id, ArchipelagoMod.LOG_NAME)

func spawn_collected_effect() -> Node2D:
	var effect: Node2D =  super()
	effect.get_node("CollectableOrb").texture = sprite_override
	return effect
