class_name CollectableMoonFragment
extends Collectable

const MOON_FRAGMENT_1: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-1.png")
const MOON_FRAGMENT_2: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-2.png")
const MOON_FRAGMENT_3: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-3.png")
const MOON_FRAGMENT_4: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-4.png")

const sprites: Dictionary[Collectable.Type, Texture2D] = {
	Collectable.Type.FRAGMENT_1: MOON_FRAGMENT_1,
	Collectable.Type.FRAGMENT_2: MOON_FRAGMENT_2,
	Collectable.Type.FRAGMENT_3: MOON_FRAGMENT_3, 
	Collectable.Type.FRAGMENT_4: MOON_FRAGMENT_4
}

func _ready() -> void:
	# make progressive
	update_progressive_type()
	ArchipelagoMod.instance.ap_item_received.connect(_on_item_received)
	super()

func on_collected() -> void:
	ModLoaderLog.info("on_Collected Moon Fragment item %s" % name, ArchipelagoMod.LOG_NAME)
	super()

func update_progressive_type() -> void:
	type = ArchipelagoManager.get_next_fragment()
	icon = sprites[type]
	if is_node_ready():
		sprite.texture = sprites[type]
		selected_outline.texture = sprites[type]

func _on_item_received() -> void:
	update_progressive_type()
