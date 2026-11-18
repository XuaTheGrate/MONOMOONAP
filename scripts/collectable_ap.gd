class_name CollectableAP
extends Collectable

@export var location_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = (1 << 14) as Collectable.Type
	super()

func on_collected() -> void:
	ModLoaderLog.info("on_Collected AP item %s" % name, ArchipelagoMod.LOG_NAME)
	super()
