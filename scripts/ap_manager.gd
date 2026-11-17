extends Node

const collectible_ap: PackedScene = preload("res://mods-unpacked/MayaXTG-Archipelago/scenes/collectible_ap.tscn")

var collectibles = [
	#APitemId, Region, coords, type, node_name
	[1000, 'Glade', '13;13', 'Map', 'CollectableMap'],
	[1001, 'City', '21;1', 'Conch', 'CollectableConch'],
	[1002, 'Coast', 'N/A', 'Lyre', 'CollectableInstrument'],
	[1003, 'Lab', '17;12', 'Map Markers', 'CollectableMarkers'],
	[2000, 'Glade', '18;14', 'Feather', 'CollectablePageRS'],
	[2001, 'Glade', '21;14', 'Feather', 'CollectablePageMM'],
	[2002, 'Glade', '12;12', 'Feather', 'CollectablePageCU'],
	[2003, 'Glade', '12;16', 'Feather', 'CollectablePageC'],
	[2004, 'Castle','N/A', 'Feather', 'CollectablePageCI'],
	[2005, 'Castle','N/A', 'Feather', 'CollectablePageCPM'],
	[2006, 'Glade', '10;14', 'Feather', 'CollectablePageSDMG'],
	[2007, 'Den', '24;13', 'Feather', 'CollectablePageCO'],
	[2008, 'Den', '23;12', 'Feather', 'CollectablePageDC'],
	[2009, 'Den', '23;10', 'Feather', 'CollectablePageMG'],
	[2010, 'Forest', '27;17', 'Feather', 'CollectablePageEDMG'],
	[2011, 'Catacombs', '25;8', 'Feather', 'CollectablePageCRB'],
	[2012, 'Swamp', '3;9', 'Feather', 'CollectablePageS'],
	[2013, 'Cliffs', '7;17', 'Feather', 'CollectablePageT'],
	[2014, 'Swamp', '13;7', 'Feather', 'CollectablePageCR'],
	[2015, 'Waterworks', '13;11', 'Feather', 'CollectablePageWWWW'],
	[2016, 'Waterworks', '9;10', 'Feather', 'CollectablePageWM'],
	[2017, 'City', '27;3', 'Feather', 'CollectablePageCM'],
	[2018, 'City', '27;9', 'Feather', 'CollectablePageET'],
	[2019, 'Swamp', '7;9', 'Feather', 'CollectablePageSC'],
	[2020, 'Coast', '10;4', 'Feather', 'CollectablePageWDMG'],
	[2021, 'Coast', '4;3', 'Feather', 'CollectablePageWDPH'],
	[2022, 'Swamp', '10;7', 'Feather', 'CollectablePageSDPH'],
	[2023, 'Lab', '16;12', 'Feather', 'CollectablePageCD'],
	[2024, 'Tundra', '2;13', 'Feather', 'CollectablePageCRS'],
	[2025, 'City', '23;6', 'Feather', 'CollectablePageCDW'],
	[2026, 'Sky Ruins', '19;16', 'Feather', 'CollectablePageE'],
	[2027, 'Bamboo Forest', '11;1', 'Feather', 'CollectablePageR'],
	[3000, 'Glade', '13;15', 'Yellow Orb', 'CollectableOrb'],
	[3001, 'Glade', '11;16', 'Yellow Orb', 'CollectableOrb2'],
	[3002, 'Cliffs', '1;16', 'Blue Orb', 'CollectableOrb3'],
	[3003, 'Tundra', '2;14', 'Blue Orb', 'CollectableOrb4'],
	[3004, 'Tundra', '5;11', 'Blue Orb', 'CollectableOrb5'],
	[3005, 'Waterworks', '8;9', 'Blue Orb', 'CollectableOrb6'],
	[3006, 'Swamp', '8;7', 'Red Orb', 'CollectableOrb7'],
	[3007, 'Waterworks', '12;10', 'Blue Orb', 'CollectableOrb8'],
	[3008, 'Lab', '16;10', 'Yellow Orb', 'CollectableOrb9'],
	[3009, 'Catacombs', '18;8', 'Yellow Orb', 'CollectableOrb10'],
	[3010, 'City', '28;5', 'Red Orb', 'CollectableOrb11'],
	[3011, 'Catacombs', '26;8', 'Green Orb', 'CollectableOrb12'],
	[3012, 'Cavern', '28;12', 'Green Orb', 'CollectableOrb13'],
	[3013, 'Cavern', '25;12', 'Green Orb', 'CollectableOrb14'],
	[3014, 'Forest', '28;15', 'Green Orb', 'CollectableOrb15'],
	[3015, 'Den', '23;13', 'Green Orb', 'CollectableOrb16'],
	[3016, 'Forest', '25;18', 'Yellow Orb', 'CollectableOrb17'],
	[3017, 'Glade', '6;14', 'Blue Orb', 'CollectableOrb18'],
	[3018, 'Glade', '16;17', 'Yellow Orb', 'CollectableOrb19'],
	[3019, 'Den', '21;13', 'Yellow Orb', 'CollectableOrb20'],
	[3020, 'Den', '22;10', 'Green Orb', 'CollectableOrb21'],
	[3021, 'Swamp', '4;11', 'Blue Orb', 'CollectableOrb22'],
	[3022, 'Sea Cave', '7;3', 'Red Orb', 'CollectableOrb23'],
	[3023, 'Coast', '5;1', 'Red Orb', 'CollectableOrb24'],
	[3024, 'Abyss', '17;2', 'Red Orb', 'CollectableOrb25'],
	[3025, 'City', '24;6', 'Red Orb', 'CollectableOrb26'],
	[3026, 'Coast', '5;5', 'Red Orb', 'CollectableOrb27'],
	[3027, 'Catacombs', '23;7', 'Green Orb', 'CollectableOrb28'],
	[4000, 'Glade', '16;14', 'Golden Feather', 'CollectableGoldenQuill3'],
	[4001, 'Castle', 'N/A', 'Golden Feather', 'CollectableGoldenQuill2'],
	[4002, 'Elevator', 'N/A', 'Golden Feather', 'CollectableGoldenQuill'],
	[4003, 'Abyss', '14;2', 'Golden Feather', 'CollectableGoldenQuill4'],
	[4004, 'Sea Cave', '13;2', 'Golden Feather', 'CollectableGoldenQuill5'],
	[5000, 'Catacombs', '23;9', 'Relic', 'CollectableTrophy'],
	[5001, 'Cliffs', '5;18', 'Relic', 'CollectableTrophyAmulet'],
	[5002, 'Cliffs', '9;18', 'Relic', 'CollectableTrophyFruit'],
	[5003, 'Abyss', '13;3', 'Relic', 'CollectableTrophyMirror'],
	[5004, 'City', '28;6', 'Relic', 'CollectableTrophyHourglass'],
	[5005, 'Temple', '16;4', 'Relic', 'CollectableTrophyWand'],
	[5006, 'City', '22;6', 'Relic', 'CollectableTrophy'],
	[5007, 'Sky Ruins', '19;17', 'Relic', 'CollectableTrophy'],
	[6000, 'Forest', '22;16', 'Moon Piece', 'OwlTelescope'],
	[6001, 'City', '27;11', 'Moon Piece', 'RabbitTelescope2'],
	[6002, 'Coast', '3;8', 'Moon Piece', 'FishTelescope3'],
	[6003, 'Cliffs', '3;16', 'Moon Piece', 'BigTelescope']
]

var collectible_by_name = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for row in collectibles:
		collectible_by_name[row[4]] = row
	get_tree().node_added.connect(_on_node_added)

func _swap_for_ap(original: Collectable, ap_data) -> void:
	print("[AP] swapping out collectable ", original.name)
	var ap := collectible_ap.instantiate()
	ap.position = original.position
	original.get_parent().add_child(ap)
	original.queue_free()
	

func _on_node_added(node: Node):
	if node.name in collectible_by_name:
		_swap_for_ap.call_deferred(node, collectible_by_name[node.name])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
