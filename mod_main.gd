class_name ArchipelagoMod
extends Node

const MOD_DIR: String = "MayaXTG-Archipelago"
const LOG_NAME: String = "MayaXTG-Archipelago:Main"
const VERSION: String = "0.0.1"

var mod_dir_path: String = ""
var extensions_dir_path: String = ""
var translations_dir_path: String = ""

static var instance: ArchipelagoMod

signal ap_location_collected(location_id: int)
signal ap_item_received(item: Variant) # TODO

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
	
	# instatiates the main bridge between the game and the ap server
	add_child(preload("res://mods-unpacked/MayaXTG-Archipelago/scripts/ap_manager.gd").new())
