extends "res://gg/scripts/game/objects/relic_slot_machine.gd"

var collectable_trophy_ap: CollectableAP

func _grandparent_ready() -> void:
	if Engine.is_editor_hint(): return
	if animation_player == null:
		animation_player = $AnimationPlayer
	if not interact_area.interacted.is_connected(_on_interact_area_interacted):
		interact_area.interacted.connect(_on_interact_area_interacted)

	_reset_moon_symbol()
	if door_type == GameState.DoorType.NONE: return
	if GameGlobals.loading_state < GameSignals.LoadingState.LOADING_STARTED:
		await GameSignals.loading_started
	if door_moon_effect:
		door_moon_effect.clear()
	if door_opened_effect:
		door_opened_effect.clear()
	if door_type in GameState.open_doors:
		_on_door_opened.call_deferred(door_type)
	else:
		GameSignals.door_opened.connect(_on_door_opened)

func _ready() -> void:
	_grandparent_ready()
	if Engine.is_editor_hint(): return

	if GameGlobals.loading_state < GameSignals.LoadingState.PREPARE_GAME:
		await GameSignals.prepare_game
		
	collectable_trophy_ap = get_node('RelicMachine/Mask/CollectableTrophy')

	if not collectable_trophy_ap or collectable_trophy_ap._collected:
		_on_door_opened(door_type)
	else:

		collectable_trophy_ap.can_be_collected = false
		locked_feedback.connect(_on_door_locked_feedback)
	GameSignals.game_saved.connect(_on_game_saved)
	

func door_considered_opened() -> void :
	super ()
	if collectable_trophy_ap:
		collectable_trophy_ap.can_be_collected = true

		collectable_trophy_ap.reparent(get_parent())
