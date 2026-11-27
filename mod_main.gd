class_name ArchipelagoMod
extends Node

const MOD_DIR: String = "MayaXTG-Archipelago"
const LOG_NAME: String = "MayaXTG-Archipelago:Main"
const VERSION: String = "0.1.1"

const AP_COLLECTABLE_TYPE: Collectable.Type = (1 << 16) as Collectable.Type

enum RelicType {
	Crown,     # 5007
	Skull,     # 5000
	Scales,    # 5006
	Mirror,    # 5003
	Fruit,     # 5002
	Amulet,    # 5001
	Hourglass, # 5004
	Wand,      # 5005
}

var mod_dir_path: String = ""
var extensions_dir_path: String = ""
var translations_dir_path: String = ""

static var instance: ArchipelagoMod

var ws: ArchipelagoWS
var manager: ArchipelagoManager
var ancient_to_id: Dictionary[GameGlobals.AncientType, int] = {
	GameGlobals.AncientType.OWL: 6000,
	GameGlobals.AncientType.RABBIT: 6001,
	GameGlobals.AncientType.FISH: 6002,
	GameGlobals.AncientType.WOLF: 6003
}
var ancient_sprite_overrides: Dictionary[GameGlobals.AncientType, Texture2D] = {}

var player_id: int:
	get: return ws._player_id

## Emit this signal from the game to tell the websocket to dispatch the location.
signal ap_location_collected(location_id: int)
## Emit this signal from the websocket to give the item to the player.
signal ap_item_received(item: APWSClasses.NetworkItem)

signal ap_ws_connected
signal ap_ws_connection_failure(reason: String)

func _init() -> void:
	if instance != null and is_instance_valid(instance):
		ModLoaderLog.error("ArchipelagoMod already instanced", LOG_NAME)
		queue_free()
		return
	instance = self
	
	ModLoaderLog.info("Init", LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
	install_script_extensions()

func install_script_extensions() -> void:
	pass

func _ready() -> void:
	ModLoaderLog.info("Ready", LOG_NAME)
	
	# handles low level websocket connection
	if ws == null:
		ws = preload("res://mods-unpacked/MayaXTG-Archipelago/scripts/ap_websocket/ap_websocket.gd").new()
		add_child(ws)
	
	# instatiates the main bridge between the game and the ap server
	if manager == null:
		manager = preload("res://mods-unpacked/MayaXTG-Archipelago/scripts/ap_manager.gd").new()
		add_child(manager)
	
	GameSignals.collectable_collected.connect(_on_collectable_collected)
	ap_location_collected.connect(_on_ap_location_collected)
	ws.packet_received_items.connect(_on_ws_packet_received_items)

func connect_to_ap(address: String, port: String, slot: String, password: String) -> void:
	ws.address = address
	ws.port = port
	ws.slot = slot
	ws.password = password
	ws.connect_to_ap()

func disconnect_from_ap() -> void:
	ws.disconnect_from_ap()

func get_location_scouts(locations: Array[int]) -> Array[APWSClasses.NetworkItem]:
	ws.request_location_scouts(locations)
	var loc: APWSClasses.LocationInfo = await ws.packet_location_info
	return loc.locations

func _on_collectable_collected(collectable: Collectable) -> void:
	if collectable is CollectableAP:
		ap_location_collected.emit(collectable.location_id)

func _on_ap_location_collected(location: int) -> void:
	ws.queue_send_location(location)

func _on_ws_packet_received_items(packet: APWSClasses.ReceivedItems) -> void:
	ModLoaderLog.info("Received items: %s" % [packet.items], LOG_NAME)
	for item: APWSClasses.NetworkItem in packet.items:
		# in this case, item.location is the remote location, and item.player is the sending player
		# local items also get emitted from this function
		ap_item_received.emit(item)
