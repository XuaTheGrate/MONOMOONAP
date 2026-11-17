extends Collectable

@export var location_id: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = (1 << 14) as Collectable.Type
	super()

func on_collected() -> void:
	prints("[ARCHIPELAGO] on_Collected AP item")
	super()

func set_collected() -> void:
	prints("[ARCHIPELAGO] set_Collected AP item")
	super()
