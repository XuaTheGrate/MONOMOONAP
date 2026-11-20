class_name ArchipelagoManager
extends Node

const collectible_ap: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")
const collectible_moon_piece: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_moon_fragment.tscn")

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

var node_by_name: Dictionary[String, Node2D]

func _on_node_added(node: Node) -> void:
	if node.name == 'OutsideLevel':
		node.ready.connect(_node_scan_complete, CONNECT_ONE_SHOT)
	if node.name in collectible_by_node_name:
		# This node corresponds to a pickup location, save the position
		# so we can replace it with another pickup, a custom local pickup, or an AP logo
		node_by_name[node.name] = node
	
	#TODO: move this to the appropriate place
	if node is AncientConversation:
		ancient_conversation_override(node)
	
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
	ModLoaderLog.debug("Received location scouts: %s" % scouts, ArchipelagoMod.LOG_NAME)
	
	# Shuffle (using scout data)
	ModLoaderLog.info("shuffling items:%d" % len(scouts), ArchipelagoMod.LOG_NAME)
	for raw_loc:RawCollectible in collectibles:
		# The location we are considering
		var location_id: int = raw_loc.location_id

		# What goes here?
		var scout: APWSClasses.NetworkItem = scout_by_id[location_id]
		
		# Is it just a normal pickup location?
		if raw_loc.is_basic():
			var original: Node2D = node_by_name[raw_loc.node_name]
			
			#TODO: check if scout has found item of this world
			var is_local_item: bool = true
			var item_id:int = scout.item
			# Is there an exisitng node of this item?
			var pool: Array[Node2D] = []
			if item_id in original_nodes_by_item_id:
				pool = original_nodes_by_item_id[item_id]
			# No there isn't
			if not pool:
				# So we need to create our own Node
				if is_local_item:
					# if it's a local item, create it with it's own icon
					var raw_item: RawCollectible = collectible_by_item_id.get(item_id)
					if raw_item.type == 'Moon Piece':
						_place_moon_piece_at(original, raw_loc.loc_name, raw_loc.location_id)
					else:
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
	ModLoaderLog.info("moving collectible %s -> %s" % [node_to_move.name, original.name], ArchipelagoMod.LOG_NAME)
	node_to_move.reparent(original_parents[original.name])
	node_to_move.position = original_positions[original.name]
	NODE_TO_ID[node_to_move.name] = location_id
	
func _place_ap_at(original: Node2D, location_name: String, location_id:int) -> void:
	ModLoaderLog.info("Spawning AP collectible at %s" % location_name, ArchipelagoMod.LOG_NAME)
	var ap: Collectable = collectible_ap.instantiate()
	_place_at(ap, original, location_id)
	

func _place_moon_piece_at(original: Node2D, location_name: String, location_id:int) -> void:
	ModLoaderLog.info("Spawning moon piece collectible at %s" % location_name, ArchipelagoMod.LOG_NAME)
	var ap: CollectableMoonFragment = collectible_moon_piece.instantiate()
	_place_at(ap, original, location_id)

func _place_at(ap:Collectable, original:Node2D, location_id: int) -> void:
	ap.name += str(location_id)
	original_parents[original.name].add_child(ap)
	ap.position = original_positions[original.name]	
	NODE_TO_ID[ap.name] = location_id
	

#TODO: use this
func ancient_conversation_override(conv: AncientConversationOverride) -> void:
	# replace with item sprite
	conv.sprite_override = preload("res://mods-unpacked/MayaXTG-Archipelago/assets/collectible_ap.png")
	conv.ap_location = 0 # TODO
