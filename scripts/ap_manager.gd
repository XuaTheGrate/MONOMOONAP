extends Node

const collectible_ap: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")

class RawCollectible:
	var ap_id: int
	var region: String
	var coords: String
	var collectible_type: String
	var node_name: String
	
	func _init(p_ap_id: int, p_region: String, p_coords: String, p_type: String, p_node_name: String) -> void:
		ap_id = p_ap_id
		region = p_region
		coords = p_coords
		collectible_type = p_type
		node_name = p_node_name
	

var collectibles: Array[RawCollectible] = [
	RawCollectible.new(1000, 'Glade', '13;13', 'Map', 'CollectableMap'),
	RawCollectible.new(1001, 'City', '21;1', 'Conch', 'CollectableConch'),
	RawCollectible.new(1002, 'Coast', 'N/A', 'Lyre', 'CollectableInstrument'),
	RawCollectible.new(1003, 'Lab', '17;12', 'Map Markers', 'CollectableMarkers'),
	RawCollectible.new(2000, 'Glade', '18;14', 'Feather', 'CollectablePageRS'),
	RawCollectible.new(2001, 'Glade', '21;14', 'Feather', 'CollectablePageMM'),
	RawCollectible.new(2002, 'Glade', '12;12', 'Feather', 'CollectablePageCU'),
	RawCollectible.new(2003, 'Glade', '12;16', 'Feather', 'CollectablePageC'),
	RawCollectible.new(2004, 'Castle','N/A', 'Feather', 'CollectablePageCI'),
	RawCollectible.new(2005, 'Castle','N/A', 'Feather', 'CollectablePageCPM'),
	RawCollectible.new(2006, 'Glade', '10;14', 'Feather', 'CollectablePageSDMG'),
	RawCollectible.new(2007, 'Den', '24;13', 'Feather', 'CollectablePageCO'),
	RawCollectible.new(2008, 'Den', '23;12', 'Feather', 'CollectablePageDC'),
	RawCollectible.new(2009, 'Den', '23;10', 'Feather', 'CollectablePageMG'),
	RawCollectible.new(2010, 'Forest', '27;17', 'Feather', 'CollectablePageEDMG'),
	RawCollectible.new(2011, 'Catacombs', '25;8', 'Feather', 'CollectablePageCRB'),
	RawCollectible.new(2012, 'Swamp', '3;9', 'Feather', 'CollectablePageS'),
	RawCollectible.new(2013, 'Cliffs', '7;17', 'Feather', 'CollectablePageT'),
	RawCollectible.new(2014, 'Swamp', '13;7', 'Feather', 'CollectablePageCR'),
	RawCollectible.new(2015, 'Waterworks', '13;11', 'Feather', 'CollectablePageWWWW'),
	RawCollectible.new(2016, 'Waterworks', '9;10', 'Feather', 'CollectablePageWM'),
	RawCollectible.new(2017, 'City', '27;3', 'Feather', 'CollectablePageCM'),
	RawCollectible.new(2018, 'City', '27;9', 'Feather', 'CollectablePageET'),
	RawCollectible.new(2019, 'Swamp', '7;9', 'Feather', 'CollectablePageSC'),
	RawCollectible.new(2020, 'Coast', '10;4', 'Feather', 'CollectablePageWDMG'),
	RawCollectible.new(2021, 'Coast', '4;3', 'Feather', 'CollectablePageWDPH'),
	RawCollectible.new(2022, 'Swamp', '10;7', 'Feather', 'CollectablePageSDPH'),
	RawCollectible.new(2023, 'Lab', '16;12', 'Feather', 'CollectablePageCD'),
	RawCollectible.new(2024, 'Tundra', '2;13', 'Feather', 'CollectablePageCRS'),
	RawCollectible.new(2025, 'City', '23;6', 'Feather', 'CollectablePageCDW'),
	RawCollectible.new(2026, 'Sky Ruins', '19;16', 'Feather', 'CollectablePageE'),
	RawCollectible.new(2027, 'Bamboo Forest', '11;1', 'Feather', 'CollectablePageR'),
	RawCollectible.new(3000, 'Glade', '13;15', 'Yellow Orb', 'CollectableOrb'),
	RawCollectible.new(3001, 'Glade', '11;16', 'Yellow Orb', 'CollectableOrb2'),
	RawCollectible.new(3002, 'Cliffs', '1;16', 'Blue Orb', 'CollectableOrb3'),
	RawCollectible.new(3003, 'Tundra', '2;14', 'Blue Orb', 'CollectableOrb4'),
	RawCollectible.new(3004, 'Tundra', '5;11', 'Blue Orb', 'CollectableOrb5'),
	RawCollectible.new(3005, 'Waterworks', '8;9', 'Blue Orb', 'CollectableOrb6'),
	RawCollectible.new(3006, 'Swamp', '8;7', 'Red Orb', 'CollectableOrb7'),
	RawCollectible.new(3007, 'Waterworks', '12;10', 'Blue Orb', 'CollectableOrb8'),
	RawCollectible.new(3008, 'Lab', '16;10', 'Yellow Orb', 'CollectableOrb9'),
	RawCollectible.new(3009, 'Catacombs', '18;8', 'Yellow Orb', 'CollectableOrb10'),
	RawCollectible.new(3010, 'City', '28;5', 'Red Orb', 'CollectableOrb11'),
	RawCollectible.new(3011, 'Catacombs', '26;8', 'Green Orb', 'CollectableOrb12'),
	RawCollectible.new(3012, 'Cavern', '28;12', 'Green Orb', 'CollectableOrb13'),
	RawCollectible.new(3013, 'Cavern', '25;12', 'Green Orb', 'CollectableOrb14'),
	RawCollectible.new(3014, 'Forest', '28;15', 'Green Orb', 'CollectableOrb15'),
	RawCollectible.new(3015, 'Den', '23;13', 'Green Orb', 'CollectableOrb16'),
	RawCollectible.new(3016, 'Forest', '25;18', 'Yellow Orb', 'CollectableOrb17'),
	RawCollectible.new(3017, 'Glade', '6;14', 'Blue Orb', 'CollectableOrb18'),
	RawCollectible.new(3018, 'Glade', '16;17', 'Yellow Orb', 'CollectableOrb19'),
	RawCollectible.new(3019, 'Den', '21;13', 'Yellow Orb', 'CollectableOrb20'),
	RawCollectible.new(3020, 'Den', '22;10', 'Green Orb', 'CollectableOrb21'),
	RawCollectible.new(3021, 'Swamp', '4;11', 'Blue Orb', 'CollectableOrb22'),
	RawCollectible.new(3022, 'Sea Cave', '7;3', 'Red Orb', 'CollectableOrb23'),
	RawCollectible.new(3023, 'Coast', '5;1', 'Red Orb', 'CollectableOrb24'),
	RawCollectible.new(3024, 'Abyss', '17;2', 'Red Orb', 'CollectableOrb25'),
	RawCollectible.new(3025, 'City', '24;6', 'Red Orb', 'CollectableOrb26'),
	RawCollectible.new(3026, 'Coast', '5;5', 'Red Orb', 'CollectableOrb27'),
	RawCollectible.new(3027, 'Catacombs', '23;7', 'Green Orb', 'CollectableOrb28'),
	RawCollectible.new(4000, 'Glade', '16;14', 'Golden Feather', 'CollectableGoldenQuill3'),
	RawCollectible.new(4001, 'Castle', 'N/A', 'Golden Feather', 'CollectableGoldenQuill2'),
	RawCollectible.new(4002, 'Elevator', 'N/A', 'Golden Feather', 'CollectableGoldenQuill'),
	RawCollectible.new(4003, 'Abyss', '14;2', 'Golden Feather', 'CollectableGoldenQuill4'),
	RawCollectible.new(4004, 'Sea Cave', '13;2', 'Golden Feather', 'CollectableGoldenQuill5'),
	RawCollectible.new(5000, 'Catacombs', '23;9', 'Relic', 'CollectableTrophy'),
	RawCollectible.new(5001, 'Cliffs', '5;18', 'Relic', 'CollectableTrophyAmulet'),
	RawCollectible.new(5002, 'Cliffs', '9;18', 'Relic', 'CollectableTrophyFruit'),
	RawCollectible.new(5003, 'Abyss', '13;3', 'Relic', 'CollectableTrophyMirror'),
	RawCollectible.new(5004, 'City', '28;6', 'Relic', 'CollectableTrophyHourglass'),
	RawCollectible.new(5005, 'Temple', '16;4', 'Relic', 'CollectableTrophyWand'),
	RawCollectible.new(5006, 'City', '22;6', 'Relic', 'CollectableTrophy'),
	RawCollectible.new(5007, 'Sky Ruins', '19;17', 'Relic', 'CollectableTrophy'),
	RawCollectible.new(6000, 'Forest', '22;16', 'Moon Piece', 'OwlTelescope'),
	RawCollectible.new(6001, 'City', '27;11', 'Moon Piece', 'RabbitTelescope2'),
	RawCollectible.new(6002, 'Coast', '3;8', 'Moon Piece', 'FishTelescope3'),
	RawCollectible.new(6003, 'Cliffs', '3;16', 'Moon Piece', 'BigTelescope')
]

var collectible_by_name: Dictionary[String, RawCollectible] = {}
# used to simulate rando
var unplaced: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for row:RawCollectible in collectibles:
		collectible_by_name[row.node_name] = row
		unplaced.append(row)

	get_tree().node_added.connect(_on_node_added)

var index:int = 0
func _swap_for_ap(original: Collectable, _ap_data: RawCollectible) -> void:
	print("[AP] swapping out collectible ", original.name)
	var ap :Collectable = collectible_ap.instantiate()
	ap.position = original.position
	original.get_parent().add_child(ap)
	original.queue_free()

func _on_node_added(node: Node) -> void:
	if node.name == 'OutsideLevel':
		node.ready.connect(_ap_shuffle, CONNECT_ONE_SHOT)
	if node.name in collectible_by_name:
		# test for when this location is an external AP item
		#_swap_for_ap.call_deferred(node, collectible_by_name[node.name])
		# test for when this location is an item from this game
		_save_ap_location(node, collectible_by_name[node.name])

var node_by_name: Dictionary[String, Collectable] = {}
func _save_ap_location(node:Node, _ap_data: RawCollectible) -> void:
	node_by_name[node.name] = node

func _ap_shuffle() -> void:
	# Save all global positions
	var original_positions: Dictionary[String, Vector2] = {}
	var original_parent: Dictionary[String, Node2D] = {}
	for key: String in node_by_name:
		var node: Node2D = node_by_name[key]
		original_positions[key] = node.position
		original_parent[key] = node.parent
	
	# Shuffle (simulate rando)
	unplaced.shuffle()
	for key: String in node_by_name:
		var node: Collectable = node_by_name[key]
		var next_collectible: RawCollectible = unplaced.pop_front()
		node.position = original_positions[next_collectible.node_name]
		# NOTE: we'll need to sort out the telescopes spearately,
		# and the clam item, and probably others
	print("[AP] item shuffle complete")
	
