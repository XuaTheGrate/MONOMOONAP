extends Area2D

enum Type{
	PAGE = 0, 
	MAP = 1 << 0, 
	MARKERS = 1 << 5, 
	CONCH = 1 << 1, 
	POST_CONCH = 1 << 14, 
	SHRIMP_CONCH = 1 << 15, 
	BOOK = 1 << 2, 
	COMPASS = 1 << 3, 
	INSTRUMENT = 1 << 4, 
	CANDLE = 1 << 10, 
	FRAGMENT_1 = 1 << 6, 
	FRAGMENT_2 = 1 << 7, 
	FRAGMENT_3 = 1 << 8, 
	FRAGMENT_4 = 1 << 9, 
	TROPHY = 1 << 11, 
	ORB = 1 << 12, 
	GOLDEN_QUILL = 1 << 13, 
	ARCHIPELAGO = 1 << 14,
}

@onready var interactable_arrow: InteractableArrow = $InteractableArrow
@onready var selected_outline: Sprite2D = %SelectedOutline
@onready var sprite: Sprite2D = %Sprite

signal collected()

@export var icon: Texture2D
@export var type: Type
@export var collected_effect: PackedScene
@export var interact_action: GUIDEAction
@export var special_close_popup_sound: AudioClipConfig
@export var fake_map_position: FakeMapPositionArea
@export var play_collected_animation: bool
@export var animation_player: AnimationPlayer
@export var display_name: String
@export var conch_offset: Vector2

var position_for_map: Vector2:
	get():
		if fake_map_position:
			return fake_map_position.get_fake_position(global_position)
		return global_position

var can_be_collected: bool = true:
	set(value):
		if can_be_collected == value: return
		can_be_collected = value
		if _is_player_in_range:
			_on_body_entered(GameGlobals.player)

var _collected: bool
var _is_player_in_range: bool

func _ready() -> void :
	if Engine.is_editor_hint(): return
	if GameGlobals.loading_state < GameSignals.LoadingState.CREATE_OBJECTS:
		await GameSignals.create_objects
	if type not in [Collectable.Type.PAGE, Collectable.Type.ORB, Collectable.Type.TROPHY, Collectable.Type.GOLDEN_QUILL]\
	and type in GameState.items:
		set_collected()
		return
	if collected_effect:
		GameSignals.request_load_packed_scene.emit(collected_effect)
	GameSignals.register_collectable.emit(self)
	if _collected: return

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	selected_outline.visible = false

	GameSignals.console_give_collectable.connect( func(collectable: Type) -> void :
		if collectable == type:
			on_collected())

func on_collected() -> void :
	if _collected: return
	if not can_be_collected: return
	GG.logt(GG.LogTag.Gameplay, "Collected", name)
	GG.safe_disconnect(interact_action.triggered, on_collected)
	GameGlobals.player.is_picking_up_item = true
	spawn_collected_effect()
	if animation_player and play_collected_animation:
		_collected = true
		interactable_arrow.allow_to_show = false
		selected_outline.visible = false
		animation_player.play(&"collected")
		await animation_player.animation_finished

	GameGlobals.player.is_picking_up_item = false
	set_collected()

func set_collected() -> void :



	collected.emit()
	if not can_be_collected: return
	GameSignals.collectable_collected.emit(self)
	_collected = true
	queue_free()

func spawn_collected_effect() -> Node2D:
	if not collected_effect: return null
	var effect: Node2D = collected_effect.instantiate()
	get_parent().add_child(effect)
	effect.global_position = global_position
	return effect

func _on_body_entered(body: Node2D) -> void :
	if Engine.is_editor_hint(): return
	_is_player_in_range = true
	if _collected or not can_be_collected: return
	if body is MovementController or body is Submarine:
		interactable_arrow.allow_to_show = true
		GG.safe_connect(interact_action.triggered, on_collected)
		selected_outline.visible = true

func _on_body_exited(body: Node2D) -> void :
	if Engine.is_editor_hint(): return
	_is_player_in_range = false
	if _collected: return
	if body is MovementController or body is Submarine:
		interactable_arrow.allow_to_show = false
		GG.safe_disconnect(interact_action.triggered, on_collected)
		selected_outline.visible = false
