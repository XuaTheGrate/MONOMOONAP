class_name CollectableAP
extends Collectable

const ITEM_AP: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")
const ITEM_MAP: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_map.tscn")
const ITEM_CONCH: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_conch.tscn")
const ITEM_LYRE: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_instrument.tscn")
const ITEM_MARKERS: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_markers.tscn")
const ITEM_PAGE: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_page.tscn")
const ITEM_ORB: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_orb.tscn")
const ITEM_RELIC: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_trophy.tscn")
const ITEM_GOLDEN_QUILL: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectable_golden_quill.tscn")
const ITEM_FRAGMENT: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/ap_collectables/ap_collectible_moon_fragment.tscn")

const FONT_MONOGRAM: Font = preload("res://gg/fonts/monogram-extended.ttf")
const FONT_MOONSCRIPT: Font = preload("res://gg/fonts/moonscript.ttf")

const COLOUR_PROGRESSION:Color = Color('AF99EF')
const COLOUR_USEFUL:Color = Color('6D8BE8')
const COLOUR_TRAP:Color = Color('FA8072')
const COLOUR_FILLER:Color = Color('00EEEE')

var location_id: int

static func create_new(location: int, item_id: int) -> CollectableAP:
	var s: CollectableAP
	
	match item_id:
		-1: s = ITEM_AP.instantiate()
		1000: s = ITEM_MAP.instantiate()
		1001: s = ITEM_CONCH.instantiate()
		1002: s = ITEM_LYRE.instantiate()
		1003: s = ITEM_MARKERS.instantiate()
		_:
			match item_id / 1000:
				2: s = ITEM_PAGE.instantiate()
				3:
					s = ITEM_ORB.instantiate()
					s.setup_orb(item_id)
				4: s = ITEM_GOLDEN_QUILL.instantiate()
				5:
					s = ITEM_RELIC.instantiate()
					s.setup_relic(item_id)
				6:
					# TODO: support fragment progression
					s = ITEM_FRAGMENT.instantiate()
				_:
					# TODO: support Emblems
					s = ITEM_AP.instantiate()
					ModLoaderLog.warning("Unsupported item ID %d" % item_id, ArchipelagoMod.LOG_NAME)
	
	s.location_id = location
	return s

func setup_orb(item_id: int) -> void:
	match item_id / 100:
		30: $Squasher/Sprite.frame = 0
		31: $Squasher/Sprite.frame = 2
		32: $Squasher/Sprite.frame = 3
		33: $Squasher/Sprite.frame = 1
		_: ModLoaderLog.error("Failed to handle orb item id %d" % item_id, ArchipelagoMod.LOG_NAME)

func setup_relic(item_id: int) -> void:
	match item_id:
		5000:
			$Squasher/Sprite.frame = 1
			$Squasher/Sprite/SelectedOutline.frame = 1
		5001:
			$Squasher/Sprite.frame = 5
			$Squasher/Sprite/SelectedOutline.frame = 5
		5002:
			$Squasher/Sprite.frame = 4
			$Squasher/Sprite/SelectedOutline.frame = 4
		5003:
			$Squasher/Sprite.frame = 3
			$Squasher/Sprite/SelectedOutline.frame = 3
		5004:
			$Squasher/Sprite.frame = 6
			$Squasher/Sprite/SelectedOutline.frame = 6
		5005:
			$Squasher/Sprite.frame = 7
			$Squasher/Sprite/SelectedOutline.frame = 7
		5006:
			$Squasher/Sprite.frame = 2
			$Squasher/Sprite/SelectedOutline.frame = 2
		5007:
			$Squasher/Sprite.frame = 0
			$Squasher/Sprite/SelectedOutline.frame = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	super()

func set_collected() -> void:
	super()
	ModLoaderLog.info("set_collected AP item %d" % location_id, ArchipelagoMod.LOG_NAME)

static func _show_popup_for(collectable_ap: CollectableAP, scout: APWSClasses.NetworkItem) -> void:
	var popup: ItemCollectedPopup = load(GameGlobals.inventory.new_item_popup).instantiate()
	GameGlobals.inventory.get_parent().add_child(popup)
	var info: ArchipelagoManager.ItemDisplayInfo = ArchipelagoMod.instance.manager.get_item_info_at(collectable_ap.location_id)
	
	var use_moonscript: bool = ArchipelagoMod.instance.manager.slot_data.get("moon_script_only", false)
	var font: Font = FONT_MOONSCRIPT if use_moonscript else FONT_MONOGRAM
	var font_size:int = 8 if use_moonscript else 16
	
	var item_colour: Color
	if scout.flags & 0b0001 == 0b0001:
		item_colour = COLOUR_PROGRESSION
	elif scout.flags & 0b0010 == 0b010:
		item_colour = COLOUR_USEFUL
	elif scout.flags & 0b0100 == 0b100:
		item_colour = COLOUR_TRAP
	else:
		item_colour = COLOUR_FILLER
	
	var name_text: String = "%s's" % info.player_name
	var item_text: String = info.item_name
	
	if use_moonscript:
		name_text = name_text.to_upper().replace("[", "[lb]")  # escapes "["
		item_text = item_text.to_upper().replace("[", "[lb]")
		
		var re :RegEx = RegEx.create_from_string("[^A-Z ]+")
		name_text = re.sub(name_text, "[font_size=16]$0[/font_size]", true)
		item_text = re.sub(item_text, "[font_size=16]$0[/font_size]", true)
	else:
		name_text = name_text.replace("[", "[lb]")
		item_text = item_text.replace("[", "[lb]")
		
		
	var text :String = "%s [color=#%s]%s[/color]" % [
		name_text,
		item_colour.to_html(false), 
		item_text
	]
	
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
	
	collectable_ap.display_name = 'ITEM '
	popup.show_popup(collectable_ap)
	SoundBus.item_collect.play()
	
static func show_popup_for_event_location(location_id: int) -> void:
	var scout: APWSClasses.NetworkItem = ArchipelagoMod.instance.manager.scouts[location_id]
	if scout.player == ArchipelagoMod.instance.player_id:
		# If it's a local item, a popup will be created when receiving that item from the server
		return
	
	var temp: CollectableAP = create_new(location_id, -1)
	temp.type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	temp.icon = temp.sprite_override
	_show_popup_for(temp, scout)
	temp.queue_free()


func on_collected()->void:
	await super()
	var scout: APWSClasses.NetworkItem = ArchipelagoMod.instance.manager.scouts[location_id]
	# If it's a local item, a popup will be created when receiving that item from the server
	if scout.player != ArchipelagoMod.instance.player_id:
		_show_popup_for(self, scout)

	
