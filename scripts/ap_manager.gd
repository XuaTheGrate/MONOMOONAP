class_name ArchipelagoManager
extends Node

const collectible_ap: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")
const collectible_moon_piece: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_moon_fragment.tscn")

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

#region Page type definition
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
#endregion

#region Relic definitions
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
#endregion

var NODE_TO_ID: Dictionary[String, int] = {}

func load_from_data_file(filename: String) -> Array[PackedStringArray]:
	var file :FileAccess = FileAccess.open("res://mods-unpacked/MayaXTG-Archipelago/assets/data/" + filename, FileAccess.READ)
	#var content :String = file.get_as_text()
	var lines:Array[PackedStringArray] = []
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line("\t")
		if len(row) > 1:
			lines.append(row)
	return lines

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
		return type in ['Map', 'Conch', 'Lyre', 'Map Markers', 'Quill', 'Golden Quill',
		'Yellow Orb', 'Red Orb', 'Blue Orb', 'Green Orb', 
		'Mirror Relic', 'Fruit Relic', 'Amulet relic', 'Hourglass Relic', 'Wand Relic']
	
var collectibles: Array[RawCollectible] = []
var collectible_by_location_name: Dictionary[String, RawCollectible] = {}
var collectible_by_item_name: Dictionary[String, RawCollectible] = {}
var collectible_by_item_id: Dictionary[int, RawCollectible] = {}
var collectible_by_location_id: Dictionary[int, RawCollectible] = {}
var collectible_by_node_name: Dictionary[String, RawCollectible] = {}

## This is for sprite overrides in ancient_conversation.gd
var ancient_collectibles: Dictionary[int, APWSClasses.NetworkItem] = {}

var _setup_complete: bool = false

func get_ancient_override_sprite(location_id: int) -> Texture2D:
	var item: APWSClasses.NetworkItem = ancient_collectibles.get(location_id)
	if item == null:
		ModLoaderLog.error("Attempted to get sprite override of null %d" % location_id, ArchipelagoMod.LOG_NAME)
		return AP_SPRITE
	if item.player != ArchipelagoMod.instance.player_id:
		return AP_SPRITE
	
	match item.item:
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
			match item.item / 1000:
				2: return PAGE_SPRITE
				3:
					# TODO: update item ids so orbs are 3Nxx
					match item.item / 100:
						30: return BLUE_ORB_SPRITE
						31: return GREEN_ORB_SPRITE
						32: return RED_ORB_SPRITE
						33: return YELLOW_ORB_SPRITE
				4: return GQUILL_SPRITE
				# TODO: swap this to be progressive
				6: return MOON_FRAGMENT_1
	# Fallback
	ModLoaderLog.warning("Location ID '%d' wasn't found, falling back to AP sprite" % location_id, ArchipelagoMod.LOG_NAME)
	return AP_SPRITE

func _init() -> void:
	
	var pickups_csv: Array[PackedStringArray] = load_from_data_file("pickups.csv")
	
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

	
	# We have now referenced each existing item and location (for simple pickups).
	# Next, ready will run and we will find the corresponding Nnodes.

func _ready() -> void:
	# This is to collect info on the in-game Nodes.
	# NOTE: we don't want to edit the scene directly as it would put the entire world in the mod files
	get_tree().node_added.connect(_on_node_added)
	ArchipelagoMod.instance.ap_item_received.connect(_on_ap_item_received)

var node_by_name: Dictionary[String, Node2D]

func _on_node_added(node: Node) -> void:
	if node.name == 'OutsideLevel':
		node.ready.connect(_node_scan_complete, CONNECT_ONE_SHOT)
	if node.name in collectible_by_node_name:
		# This node corresponds to a pickup location, save the position
		# so we can replace it with another pickup, a custom local pickup, or an AP logo
		node_by_name[node.name] = node
	
	# _node_scan_complete is called once the node scan is complete

var original_positions: Dictionary[String, Vector2] = {}
var original_parents: Dictionary[String, Node2D] = {}
var original_nodes_by_item_id: Dictionary[int, Array] = {}

func _node_scan_complete() -> void:
	get_tree().node_added.disconnect(_on_node_added)
	
	# Save all global positions
	for key: String in node_by_name:
		var node: Node2D = node_by_name[key]
		original_positions[key] = node.position
		original_parents[key] = node.get_parent()
	
		# Keep a reference of each node that satisfies a given item id
		# so we can move them if they ended up somewhere in the world
		# otherwise we have to delete them.
		# Some items will be instantiated, like the moon pieces, as they do not exist out in the world
		var item_id: int = collectible_by_node_name[key].item_id
		if item_id not in original_nodes_by_item_id:
			original_nodes_by_item_id[item_id] = [] as Array[Node2D]
		original_nodes_by_item_id[item_id].append(node)
	
	_ap_shuffle()
	_setup_complete = true

#NOTE: This only tested in solo randos
func _ap_shuffle() -> void:
	
	# To start, we need to know which item goes in which location according to the server
	var all_location_ids: Array[int] = []
	for row:RawCollectible in collectibles:
		all_location_ids.append(row.location_id)
	var scouts: Array[APWSClasses.NetworkItem] = await ArchipelagoMod.instance.get_location_scouts(all_location_ids)
	var scout_by_id: Dictionary[int,APWSClasses.NetworkItem] = {}
	for scout:APWSClasses.NetworkItem in scouts:
		scout_by_id[scout.location] = scout
	
	# Shuffle (using scout data)
	ModLoaderLog.info("shuffling items:%d" % len(scouts), ArchipelagoMod.LOG_NAME)
	for raw_loc:RawCollectible in collectibles:
		# The location we are considering
		var location_id: int = raw_loc.location_id

		# What goes here?
		var scout: APWSClasses.NetworkItem = scout_by_id[location_id]
		
		if scout.location / 1000 == 6:
			# this is part of a constellation override
			ModLoaderLog.debug("Assigning ancient override %d -> %d" % [scout.location, scout.item], ArchipelagoMod.LOG_NAME)
			ancient_collectibles[scout.location] = scout
			continue
		
		# Is it just a normal pickup location?
		if raw_loc.is_basic():
			var original: Node2D = node_by_name[raw_loc.node_name]
			
			var is_local_item: bool = scout.player == ArchipelagoMod.instance.player_id
			var item_id:int = scout.item
			# Is there an exisitng node of this item?
			var pool: Array[Node2D] = []
			if item_id in original_nodes_by_item_id:
				pool = original_nodes_by_item_id[item_id]
			# No there isn't
			if not pool:
				ModLoaderLog.debug("Item not in pool %d" % item_id, ArchipelagoMod.LOG_NAME)
				# So we need to create our own Node
				if is_local_item:
					ModLoaderLog.debug("Item %d is local" % item_id, ArchipelagoMod.LOG_NAME)
					# if it's a local item, create it with it's own icon
					var raw_item: RawCollectible = collectible_by_item_id.get(item_id)
					if raw_item.type == 'Moon Piece':
						_place_moon_piece_at(original, raw_loc.loc_name, raw_loc.location_id)
					else:
						ModLoaderLog.warning("Item %d does not exist in pool, this should never occur" % item_id, ArchipelagoMod.LOG_NAME)
						# Fallback
						_place_ap_at(original, raw_loc.loc_name, raw_loc.location_id)
					
				else:
					# if it's an external item, create it with AP logo
					_place_ap_at(original, raw_loc.loc_name, raw_loc.location_id)
				continue
			# Yes there is, so we move it
			var node_to_move: Node2D = pool.pop_back()
			_move_pickup(original, node_to_move, raw_loc.location_id)
			# TODO: restore ancient conversations
	
	# Anything that wasn't popped out of a pool is not an item in this world and can't be freed
	for item_id: int in original_nodes_by_item_id:
		var pool: Array[Node2D] = original_nodes_by_item_id[item_id]
		for unused_node: Node2D in pool:
			unused_node.queue_free()
	
	ModLoaderLog.info("item shuffle complete", ArchipelagoMod.LOG_NAME)

func _move_pickup(original: Node2D, node_to_move:Node2D, location_id:int) -> void:
	ModLoaderLog.debug("moving collectible %s -> %s" % [node_to_move.name, original.name], ArchipelagoMod.LOG_NAME)
	node_to_move.reparent(original_parents[original.name])
	node_to_move.position = original_positions[original.name]
	NODE_TO_ID[node_to_move.name] = location_id

func _place_ap_at(original: Node2D, location_name: String, location_id:int) -> void:
	ModLoaderLog.debug("Spawning AP collectible at %s" % location_name, ArchipelagoMod.LOG_NAME)
	var ap: Collectable = collectible_ap.instantiate()
	_place_at(ap, original, location_id)

func _place_moon_piece_at(original: Node2D, location_name: String, location_id:int) -> void:
	ModLoaderLog.debug("Spawning moon piece collectible at %s" % location_name, ArchipelagoMod.LOG_NAME)
	var ap: CollectableMoonFragment = collectible_moon_piece.instantiate()
	_place_at(ap, original, location_id)

func _place_at(ap:Collectable, original:Node2D, location_id: int) -> void:
	ap.name += str(location_id)
	original_parents[original.name].add_child(ap)
	ap.position = original_positions[original.name]	
	NODE_TO_ID[ap.name] = location_id

#region Item receive handling
func _on_ap_item_received(item: int) -> void:
	while not _setup_complete:
		ModLoaderLog.debug("Attempted to process received item before loading complete", ArchipelagoMod.LOG_NAME)
		await get_tree().create_timer(5.0).timeout
	
	ModLoaderLog.debug("Handle: %d" % item, ArchipelagoMod.LOG_NAME)
	
	var coll: Collectable
	# NOTICE: this will need to be changed if item ids get updated
	# otherwise uses the same system as the ancient sprite overrider
	match item:
		1000:
			coll = Collectable.new()
			coll.type = Collectable.Type.MAP
			coll.icon = MAP_SPRITE
			coll.display_name = "MAP"
		1001:
			coll = Collectable.new()
			coll.type = Collectable.Type.CONCH
			coll.icon = CONCH_SPRITE
			coll.display_name = "CONCH"
		1002:
			coll = Collectable.new()
			coll.type = Collectable.Type.INSTRUMENT
			coll.icon = LYRE_SPRITE
			coll.display_name = "LYRE"
		1003:
			coll = Collectable.new()
			coll.type = Collectable.Type.MARKERS
			coll.icon = MARKERS_SPRITE
			coll.display_name = "MARKERS"
		_:
			match item / 1000:
				2:
					coll = CollectablePage.new()
					coll.page_type = PAGE_TYPE[item]
					coll.type = Collectable.Type.PAGE
				3:
					# TODO: handle orbs progressively
					ModLoaderLog.debug("TODO", ArchipelagoMod.LOG_NAME)
					pass
				4:
					coll = CollectableGoldenQuill.new()
					coll.type = Collectable.Type.GOLDEN_QUILL
				5:
					coll = CollectableTrophy.new()
					coll.id = RELICS[item]
					coll.frame = coll.id
					coll.type = Collectable.Type.TROPHY
				6:
					# TODO: make progressive
					coll = CollectableMoonFragment.new()
					coll.type = Collectable.Type.FRAGMENT_1
					coll.icon = MOON_FRAGMENT_1
					coll.display_name = "MOONPIECE"
				7: pass # TODO
	
	if coll == null:
		ModLoaderLog.error("Null collectable", ArchipelagoMod.LOG_NAME)
		return
	
	# hopefully doesn't cause an explosion
	GameSignals.collectable_collected.emit(coll)
	coll.queue_free()
#endregion
