class_name CollectableAP
extends Collectable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = ArchipelagoMod.AP_COLLECTABLE_TYPE
	super()

func on_collected() -> void:
	ModLoaderLog.info("on_Collected AP item %s" % name, ArchipelagoMod.LOG_NAME)
	super()
