class_name Preferences extends Resource

@export var address: String
@export var port: String
@export var slot: String
@export var password: String

static func load() -> Preferences:
	if ResourceLoader.exists("user://ap_pref.tres"):
		return load("user://ap_pref.tres")
	return Preferences.new()

func save() -> void:
	ResourceSaver.save(self, "user://ap_pref.tres")
