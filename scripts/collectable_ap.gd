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

func on_collected()->void:
	await super()
	var popup: ItemCollectedPopup = load(GameGlobals.inventory.new_item_popup).instantiate()
	GameGlobals.inventory.get_parent().add_child(popup)
	var info: ArchipelagoManager.ItemDisplayInfo = ArchipelagoMod.instance.manager.get_item_info_at(location_id)
	
	# TODO: optional moon script
	var text :String = "%s'S %s " % [info.player_name.to_upper(), info.item_name.to_upper()]
	#var re :RegEx = RegEx.create_from_string("[^A-Z ]+")
	#var ap_text: String = re.sub(text.replace("[", "[lb]"), "[font_size=16]$0[/font_size]", true)
	self.display_name = 'ITEM '
	
	popup.show_popup(self)
	SoundBus.item_collect.play()
	
	var ap_label: Label = Label.new()
	ap_label.text = text
	ap_label.add_theme_font_override("font", load("res://gg/fonts/monogram-extended.ttf"))
	ap_label.add_theme_font_size_override("font_size", 13)
	ap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ap_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var offset_x:int = 70
	var offset_y:int = 6
	ap_label.position.x = -offset_x
	ap_label.position.y = offset_y
	ap_label.size.x = offset_x * 2
	popup.add_child(ap_label)
	
