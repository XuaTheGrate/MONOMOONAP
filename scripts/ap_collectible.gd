class_name CollectableAP
extends Collectable

func _init() -> void:
	type = (1 << 14) as Collectable.Type

func on_collected() -> void:
	prints("[ARCHIPELAGO] Collected AP item")
