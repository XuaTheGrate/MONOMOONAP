class_name ArchipelagoMod
extends Node

const MOD_DIR: String = "MayaXTG-Archipelago"
const LOG_NAME: String = "MayaXTG-Archipelago:Main"
const VERSION: String = "0.0.1"

const AP_COLLECTABLE_TYPE: Collectable.Type = (1 << 16) as Collectable.Type

var mod_dir_path: String = ""
var extensions_dir_path: String = ""
var translations_dir_path: String = ""

static var instance: ArchipelagoMod

var ws: ArchipelagoWS
var manager: ArchipelagoManager
var node_name_to_id: Dictionary[String, int] = {}

## Emit this signal from the game to tell the websocket to dispatch the location.
signal ap_location_collected(location_id: int)
## Emit this signal from the websocket to give the item to the player.
signal ap_item_received(item: Variant) # TODO

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
	ModLoaderLog.info("Collected %s (location: %d)" % [collectable.name, node_name_to_id[collectable.name]], LOG_NAME)
