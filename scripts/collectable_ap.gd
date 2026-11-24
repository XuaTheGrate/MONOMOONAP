class_name CollectableAP
extends Collectable

const SCENE: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")
const FONT_MONOGRAM: Font = preload("res://gg/fonts/monogram-extended.ttf")
const FONT_MOONSCRIPT: Font = preload("res://gg/fonts/moonscript.ttf")

var location_id: int

static func create_new(location: int, item_id: int) -> CollectableAP:
	var s: CollectableAP = SCENE.instantiate()
	s.location_id = location
	return s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	super()

func set_collected() -> void:
	super()
	ModLoaderLog.info("set_collected AP item %d" % location_id, ArchipelagoMod.LOG_NAME)

func on_collected()->void:
	await super()
	var popup: ItemCollectedPopup = load(GameGlobals.inventory.new_item_popup).instantiate()
	GameGlobals.inventory.get_parent().add_child(popup)
	var info: ArchipelagoManager.ItemDisplayInfo = ArchipelagoMod.instance.manager.get_item_info_at(location_id)
	
	var use_moonscript: bool = ArchipelagoMod.instance.manager.slot_data.get("moon_script_only", false)
	var font: Font = FONT_MOONSCRIPT if use_moonscript else FONT_MONOGRAM
	var font_size:int = 8 if use_moonscript else 16
	
	var text :String = "%s's %s " % [info.player_name, info.item_name]
	if use_moonscript:
		text = text.to_upper()
		text = text.replace("[", "[lb]") # escape "[" in player/item names
		var re :RegEx = RegEx.create_from_string("[^A-Z ]+")
		text = re.sub(text, "[font_size=16]$0[/font_size]", true)
	
	var ap_label: RichTextLabel = RichTextLabel.new()
	ap_label.bbcode_enabled = true
	ap_label.fit_content = true
	ap_label.scroll_active = false
	ap_label.text = text
	ap_label.add_theme_font_override("normal_font", font)
	ap_label.add_theme_font_size_override("normal_font_size", font_size)
	ap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ap_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var offset_x:int = 70
	var offset_y:int = 6
	ap_label.position.x = -offset_x
	ap_label.position.y = offset_y
	ap_label.size.x = offset_x * 2
	# Animate arrival
	ap_label.modulate = Color(0,0,0,0)
	var start_fade: float = 0.4333
	var end_fade: float = 0.9667
	popup.add_child(ap_label)
	ap_label.create_tween().tween_property(ap_label, "modulate", Color.WHITE, end_fade - start_fade).set_delay(start_fade)
	
	self.display_name = 'ITEM '
	popup.show_popup(self)
	SoundBus.item_collect.play()
	
