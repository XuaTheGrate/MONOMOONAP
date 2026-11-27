

class_name APCollectedEffect
extends Node2D

@onready var _orb: Sprite2D = $CollectableOrb

func set_icon(icon: Texture2D, frame:int, hframes:int, vframes:int) -> void:
	_orb.texture = icon
	_orb.hframes = hframes
	_orb.vframes = vframes
	_orb.frame = frame
	
