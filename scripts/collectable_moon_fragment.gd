class_name CollectableMoonFragment
extends Collectable

func _ready() -> void:
	# TODO: make progressive
	type = Collectable.Type.FRAGMENT_1
	super()

func on_collected() -> void:
	ModLoaderLog.info("on_Collected Moon Fragment item %s" % name, ArchipelagoMod.LOG_NAME)
	super()
