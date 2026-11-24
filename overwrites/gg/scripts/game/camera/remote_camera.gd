extends "res://gg/scripts/game/camera/remote_camera.gd"


var OVERWRITE_TYPES_TO_SHOW: Array[Collectable.Type] = [(1 << 16)] as Array[Collectable.Type]

func _ready() -> void :
	GameSignals.register_knowledge_chamber_pillar.connect( func(pillar: KnowledgeChamberPillar) -> void :
		_pillars.append(pillar)
	)
	GameSignals.register_collectable.connect( func(collectable: Collectable) -> void :
		if collectable._collected: return
		if collectable.type not in OVERWRITE_TYPES_TO_SHOW: return
		var target: Vector2 = collectable.global_position + collectable.conch_offset
		collectable_positions.append(target.round())
	)

	if GameGlobals.loading_state < GameSignals.LoadingState.LOADING_COMPLETE:
		await GameSignals.loading_complete

	GameSignals.collectable_collected.connect( func(collectable: Collectable) -> void :
		if collectable.type not in OVERWRITE_TYPES_TO_SHOW: return
		var target: Vector2 = collectable.global_position + collectable.conch_offset
		collectable_positions.erase(target.round())
	)
	_is_loaded = true
