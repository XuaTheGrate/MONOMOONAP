class_name CollectableMoonFragment
extends Collectable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = Collectable.Type.FRAGMENT_1
	super()

func on_collected() -> void:
	ModLoaderLog.info("on_Collected Moon Fragment item %s" % name, ArchipelagoMod.LOG_NAME)
	super()
