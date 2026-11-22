class_name ArchipelagoSave
extends Resource

## List of collected location IDs
@export var locations: Array[int]
## List of received item IDs
@export var items: Array[int]

func save_to_disk(seed_: String) -> void:
	ResourceSaver.save(self, "user://apsave_%s.tres" % seed_)
	ModLoaderLog.debug("Saved AP data to disk", ArchipelagoMod.LOG_NAME)

static func load_from_disk(seed_: String) -> ArchipelagoSave:
	if ResourceLoader.exists("user://apsave_%s.tres" % seed_):
		ModLoaderLog.debug("Loading existing save data", ArchipelagoMod.LOG_NAME)
		var r: ArchipelagoSave = ResourceLoader.load("user://apsave_%s.tres" % seed_, "ArchipelagoSave")
		return r
	ModLoaderLog.debug("Creating new AP save data", ArchipelagoMod.LOG_NAME)
	return ArchipelagoSave.new()
