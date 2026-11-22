class_name ArchipelagoManager
extends Node

#region Ancient sprite overrides
const MOON_FRAGMENT_1: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-1.png")
const MOON_FRAGMENT_2: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-2.png")
const MOON_FRAGMENT_3: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-3.png")
const MOON_FRAGMENT_4: Texture2D = preload("res://gg/textures/game/constellation/ancients/moon-fragment-4.png")
const CANDLE_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/items/candle.png")
const CONCH_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/items/conch.tres")
const LYRE_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/items/instrument.tres")
const MARKERS_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/items/map-markers.png")
const MAP_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/items/map.tres")
const GQUILL_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/golden-quill.png")
const PAGE_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/quill.png")
const AMULET_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_amulet.tres")
const CROWN_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_crown.tres")
const FRUIT_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_fruit.tres")
const HOURGLASS_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_hourglass.tres")
const MIRROR_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_mirror.tres")
const SCALES_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_scales.tres")
const SKULL_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_skull.tres")
const WAND_SPRITE: Texture2D = preload("res://gg/textures/game/collectables/secret-collectables/relic_wand.tres")
const BLUE_ORB_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/blue_orb.tres")
const GREEN_ORB_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/green_orb.tres")
const RED_ORB_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/red_orb.tres")
const YELLOW_ORB_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/yellow_orb.tres")
const EARTH_EMBLEM_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/earth_emblem.tres")
const STAR_EMBLEM_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/star_emblem.tres")
const WATER_EMBLEM_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/water_emblem.tres")
const CROWN_EMBLEM_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/crown_emblem.tres")
const AP_SPRITE: Texture2D = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/collectible_ap.png")
#endregion

const PAGE_TYPE: Dictionary[int, BookPage.Type] = {
	2000: BookPage.Type.RUINS_EMBLEMS,
	2001: BookPage.Type.MERGE_MONOMOON, # assumption
	2002: BookPage.Type.CANVAS_USAGE,
	2003: BookPage.Type.CONSTELLATIONS, # assumption
	2004: BookPage.Type.CASTLE_INTERIOR,
	2005: BookPage.Type.CASTLE_POWER_MECHANISM,
	2006: BookPage.Type.SKY_DRAGON_MAGIC_GRID,
	2007: BookPage.Type.CONSTELLATION_OWL,
	2008: BookPage.Type.DEN_CREATURES,
	2009: BookPage.Type.MAGIC_GRID,
	2010: BookPage.Type.EARTH_DRAGON_MAGIC_GRID,
	2011: BookPage.Type.CHEST_RITUAL_BED,
	2012: BookPage.Type.SLIDE, # NOTICE: we could tie the sliding mechanic to this item specifically
	2013: BookPage.Type.THRONE,
	2014: BookPage.Type.CANVAS_REGIONS,
	2015: BookPage.Type.WATERWORKS_WATER_WHEEL,
	2016: BookPage.Type.WATERWORKS_MAP,
	2017: BookPage.Type.CHECKPOINT_MECHANISM,
	2018: BookPage.Type.ENGINEERS_TOWER,
	2019: BookPage.Type.SWAMP_CREATURES,
	2020: BookPage.Type.WATER_DRAGON_MAGIC_GRID,
	2021: BookPage.Type.WATER_DRAGON_PUZZLE_HINT,
	2022: BookPage.Type.SKY_DRAGON_PUZZLE_HINT,
	2023: BookPage.Type.CHEST_DOOR, # assumption
	2024: BookPage.Type.CHEST_REPEL_STONE,
	2025: BookPage.Type.CHEST_DIAMONDS_WALL,
	2026: BookPage.Type.ENDING,
	2027: BookPage.Type.RELICS
}

const RELICS: Dictionary[int, int] = {
	5000: 1,
	5001: 5,
	5002: 4,
	5003: 3,
	5004: 6,
	5005: 7,
	5006: 2,
	5007: 0
}

class RawCollectible:
	var location_id: int
	var item_id: int
	var item_name: String
	var loc_name: String
	var node_name: String
	var type: String
	
	func _init(location_id: int, item_id:int, item_name: String, loc_name: String, node_name: String, type:String) -> void:
		self.location_id = location_id
		self.item_id = item_id
		self.item_name = item_name
		self.loc_name = loc_name
		self.node_name = node_name
		self.type = type
	
	func is_basic() -> bool:
		var basic_type: bool = self.type in ['Map', 'Conch', 'Lyre', 'Map Markers', 'Quill', 'Golden Quill', 'Yellow Orb', 'Red Orb', 'Blue Orb', 'Green Orb']
		var relic_placed_in_world: bool = self.item_name in ['Mirror Relic', 'Fruit Relic', 'Amulet Relic', 'Hourglass Relic', 'Wand Relic']
		return basic_type or relic_placed_in_world

var NODE_TO_ID: Dictionary[String, int] = {}

## This is for sprite overrides in ancient_conversation.gd
var ancient_collectibles: Dictionary[int, APWSClasses.NetworkItem] = {}

var scouts: Dictionary[int, APWSClasses.NetworkItem] = {}

var all_location_ids: Array[int] = []
var collectibles: Array[RawCollectible] = []
var collectible_by_location_name: Dictionary[String, RawCollectible] = {}
var collectible_by_item_name: Dictionary[String, RawCollectible] = {}
var collectible_by_item_id: Dictionary[int, RawCollectible] = {}
var collectible_by_location_id: Dictionary[int, RawCollectible] = {}
var collectible_by_node_name: Dictionary[String, RawCollectible] = {}

var _setup_complete: bool = false

## Pass -1 to get the AP sprite without a warning
func get_sprite_override(item_id: int) -> Texture2D:
	match item_id:
		-1: return AP_SPRITE
		1000: return MAP_SPRITE
		1001: return CONCH_SPRITE
		1002: return LYRE_SPRITE
		1003: return MARKERS_SPRITE
		5000: return SKULL_SPRITE
		5001: return AMULET_SPRITE
		5002: return FRUIT_SPRITE
		5003: return MIRROR_SPRITE
		5004: return HOURGLASS_SPRITE
		5005: return WAND_SPRITE
		5006: return SCALES_SPRITE
		5007: return CROWN_SPRITE
		7000: return EARTH_EMBLEM_SPRITE
		7001: return WATER_EMBLEM_SPRITE
		7002: return STAR_EMBLEM_SPRITE
		7003: return CROWN_EMBLEM_SPRITE
		_:
			match item_id / 1000:
				2: return PAGE_SPRITE
				3:
					match item_id / 100:
						30: return BLUE_ORB_SPRITE
						31: return GREEN_ORB_SPRITE
						32: return RED_ORB_SPRITE
						33: return YELLOW_ORB_SPRITE
				4: return GQUILL_SPRITE
				# TODO: swap this to be progressive
				6: return MOON_FRAGMENT_1
	# Fallback
	ModLoaderLog.warning("Item ID '%d' wasn't found, falling back to AP sprite" % item_id, ArchipelagoMod.LOG_NAME)
	return AP_SPRITE

func load_from_data_file(filename: String) -> Array[PackedStringArray]:
	var file :FileAccess = FileAccess.open("res://mods-unpacked/MayaXTG-Archipelago/assets/data/" + filename, FileAccess.READ)
	#var content :String = file.get_as_text()
	var lines:Array[PackedStringArray] = []
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line("\t")
		if len(row) > 1:
			lines.append(row)
	return lines

func _init() -> void:
	var pickups_csv: Array[PackedStringArray] = load_from_data_file("pickups.csv.txt")
	
	for line:PackedStringArray in pickups_csv:
		var ap_id:int = int(line[0])
		var item_name:String = line[1]
		var loc_name:String =  line[2]
		var type: String = line[5]
		var node_name:String = line[6]
		var item_id:int = ap_id
		if item_name in collectible_by_item_name:
			# A duplicate item (i.e. orb) only first id is kept for item id
			item_id = collectible_by_item_name[item_name].item_id
		var raw:RawCollectible = RawCollectible.new(ap_id, item_id, item_name, loc_name, node_name, type)
		collectibles.append(raw)
		collectible_by_location_name[loc_name] = raw
		collectible_by_location_id[ap_id] = raw
		if raw.is_basic():
			collectible_by_node_name[node_name] = raw
		if item_name not in collectible_by_item_name:
			collectible_by_item_name[item_name] = raw
			collectible_by_item_id[item_id] = raw
		if ap_id not in all_location_ids:
			all_location_ids.append(ap_id)

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	ArchipelagoMod.instance.ws.packet_connected.connect(_on_packet_connected, CONNECT_ONE_SHOT)
	ArchipelagoMod.instance.ap_item_received.connect(_on_ap_item_received)

func _on_packet_connected(_packet: APWSClasses.Connected) -> void:
	for item: APWSClasses.NetworkItem in await ArchipelagoMod.instance.get_location_scouts(all_location_ids):
		scouts[item.location] = item

func _on_node_added(node: Node) -> void:
	if node.name == "OutsideLevel":
		node.ready.connect(_on_outside_level_ready, CONNECT_ONE_SHOT)
	if node is Collectable and node is not CollectableAP:
		var location: int
		if node is CollectableTrophy:
			match node.id:
				ArchipelagoMod.RelicType.Skull:
					location = collectible_by_item_name["Skull Relic"].location_id
				ArchipelagoMod.RelicType.Scales:
					location = collectible_by_item_name["Scales Relic"].location_id
				ArchipelagoMod.RelicType.Crown:
					location = collectible_by_item_name["Crown Relic"].location_id
				_:
					location = collectible_by_node_name[node.name].location_id
		else:
			if not collectible_by_node_name.has(node.name):
				ModLoaderLog.error("Missing location: %s (%s)" % [node.name, node.get_path()], ArchipelagoMod.LOG_NAME)
				return
			else:
				location = collectible_by_node_name[node.name].location_id
		var item: APWSClasses.NetworkItem = scouts[location]
		var ap: CollectableAP
		if item.player == ArchipelagoMod.instance.player_id:
			ap = CollectableAP.create_new(location, scouts[location].item)
			ModLoaderLog.debug("Replaced collectable '%s' with local item %d" % [node.name, scouts[location].item], ArchipelagoMod.LOG_NAME)
		else:
			ap = CollectableAP.create_new(location, -1)
			ModLoaderLog.debug("Replaced collectable '%s' with remote item" % [node.name], ArchipelagoMod.LOG_NAME)
		ap.name = node.name
		ap.global_position = node.global_position
		node.name = "BEINGDELETED"
		node.get_parent().add_child.call_deferred(ap)
		node.queue_free()

func _on_outside_level_ready() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)
		_setup_complete = true

func _on_ap_item_received(item: int) -> void:
	while not _setup_complete:
		ModLoaderLog.debug("Received items before setup, sleeping", ArchipelagoMod.LOG_NAME)
		await get_tree().create_timer(5.0).timeout
	
	var c: Collectable
	match item:
		1000: c = preload("res://gg/scenes/game/collectables/collectable_map.tscn").instantiate()
		1001: c = preload("res://gg/scenes/game/collectables/collectable_conch.tscn").instantiate()
		1002: c = preload("res://gg/scenes/game/collectables/collectable_instrument.tscn").instantiate()
		1003: c = preload("res://gg/scenes/game/collectables/collectable_markers.tscn").instantiate()
		_:
			match item / 1000:
				2:
					c = preload("res://gg/scenes/game/collectables/orb/collectable_page.tscn").instantiate()
					c.page_type = PAGE_TYPE[item]
				3:
					c = preload("res://gg/scenes/game/collectables/orb/collectable_orb.tscn").instantiate()
					match item / 100:
						30: c.orb_color = CollectableOrb.OrbColor.BLUE
						31: c.orb_color = CollectableOrb.OrbColor.GREEN
						32: c.orb_color = CollectableOrb.OrbColor.RED
						33: c.orb_color = CollectableOrb.OrbColor.YELLOW
				4:
					c = preload("res://gg/scenes/game/collectables/orb/collectable_golden_quill.tscn").instantiate()
				5:
					c = preload("res://gg/scenes/game/collectables/trophy/collectable_trophy.tscn").instantiate()
					c.id = RELICS[item]
					c.frame = RELICS[item]
					# I think I can skip assigning the achievement? Probably
				6: pass # TODO: moon fragments
				7: pass # TODO: emblems
	if c == null:
		ModLoaderLog.warning("Skipped receiving item id %d" % item, ArchipelagoMod.LOG_NAME)
		return
	GameSignals.collectable_collected.emit(c)
	c.queue_free()
