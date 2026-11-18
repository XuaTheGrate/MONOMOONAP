@tool
extends RootMenu

@onready var gg_logo: ColorRect = $GGLogo
@onready var logo_animation_player: AnimationPlayer = $GGLogo / AnimationPlayer
@onready var play_button: Button = %PlayButton
@onready var connect_button: Button = %ConnectButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_buttons: MarginContainer = %MainMenuButtons
@onready var main_menu_additions: CanvasItem = %MainMenuAdditions
@onready var saves_menu: SavesMenu = %SavesMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var connect_menu: ConnectMenu = %ConnectMenu
@onready var version_label: Label = %VersionLabel
@onready var ap_version_label: Label = %APVersionLabel
@onready var language_select_popup: LanguageSelectPopup = %LanguageSelectPopup
@onready var message_popup: MessagePopup = %MessagePopup
@onready var music: IntroLoopMusicPlayer = $Music
@onready var loading_label: Label = %LoadingLabel
@onready var loading_progress_bar: TextureProgressBar = %LoadingProgressBar



const SLOW_FRAMES_TO_SHOW_LOADING: int = 3
const SLOW_FRAME_SECONDS: float = 0.1

const SKIPPED_INTRO_SLOW_FRAME_SECONDS: float = 0.75

const SKIPPED_INTRO_MIN_WARM_UP_PROGRESS: float = 0.75
const INPUT_NOTICE_SECONDS: float = 4.5

const SKIPPED_INTRO_LOGO_HOLD_SECONDS: float = 4.2

const LOGO_FULL_PLAY_RANGES: Array[Vector2] = [Vector2(3.2, 4.2), Vector2(4.5, 4.75)]
const MIN_LOGO_FADE_OUT_SECONDS: float = 0.25

const LOADING_LOGO_FRAMES: Array[float] = [0.0, 2.2, 4.75]

const LOADING_LOGO_FRAME_START_SECONDS: Array[float] = [0.0, 5.0, 8.0]

@export var logo_fade_out_duration: float = 2.0
@export var skip_logo_fade_out_duration: float = 1.0
@export var skip_logo_animation_time_scale: float = 1.5
@export_file("*.tscn") var credits_scene: String

@export var music_fade_in_duration: float = 1.5

@export var music_fade_out_duration: float = 1.5

var is_loading: bool
var _fading_out_logo: bool

var _is_logo_unsynced: bool
var _slow_frames_count: int
var _is_intro_skipped: bool
var _is_input_notice_skipped: bool
var _last_frame_usec: int

static var message: String
static var did_show_intro: bool

static var _did_autorun: bool

func _ready() -> void :
	if Engine.is_editor_hint(): return
	StartupProfiler.mark(&"main_menu_ready")
	_last_frame_usec = Time.get_ticks_usec()

	loading_label.visible = false
	GameGlobals.is_in_game = false
	get_tree().paused = false
	version_label.text = ProjectSettings.get_setting_with_override("application/config/version")
	ap_version_label.text = ArchipelagoMod.VERSION
	GG.logt(GG.LogTag.GameSetup, "Game Version", version_label.text)
	#RootMenu.grab_focus_prefer_hovered(main_menu_buttons, play_button)
	RootMenu.grab_focus_prefer_hovered(main_menu_buttons, connect_button)
	GameGlobals.update_mouse_mode()
	ScreenFader.set_hidden()
	GameSettings.restore_master_volume()
	ScreenFader.show_game()
	GG.set_disabled_and_hide(saves_menu)
	GG.set_disabled_and_hide(settings_menu)
	GG.set_disabled_and_hide(language_select_popup)
	_maybe_show_language_popup()

	super ()

	settings_menu.shown.connect(on_settings_menu_shown)
	saves_menu.game_starting.connect(_on_saves_menu_game_starting)

	var args: PackedStringArray = OS.get_cmdline_user_args()
	var all_args: Array = Array(OS.get_cmdline_args() + args)
	if not _did_autorun and (all_args.has("autorun") or all_args.any( func(arg: String) -> bool: return arg.begins_with("load="))):
		_did_autorun = true
		GG.logt(GG.LogTag.GameSetup, "Autorun")
		var config: ConfigFile = GameState.load_command_line_save()
		if not config:
			push_error("autorun: no saveN or load=<path> arg loaded successfully")
			return
		saves_menu.load_save_file(config)

	if message:
		GG.set_disabled_and_hide(main_menu_buttons)
		GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
		message_popup.show_message(message)
		message = ""
		await message_popup.confirmed
		GG.set_enabled_and_show(main_menu_buttons)
		GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
		#SoundBus.ignore_focus_sound(play_button)
		SoundBus.ignore_focus_sound(connect_button)
		#play_button.grab_focus()
		connect_button.grab_focus()
		return
	if did_show_intro:
		var tween: Tween = create_tween()
		var was: float = music.volume_linear
		music.volume_linear = 0.0
		tween.tween_property(music, "volume_linear", was, music_fade_in_duration)
		music.skip_intro()
		return
	did_show_intro = true
	InputManager.is_drawn_cursor_suppressed = true

	if not logo_animation_player.animation_finished.is_connected(_on_logo_animation_player_animation_finished):
		logo_animation_player.animation_finished.connect(_on_logo_animation_player_animation_finished)
	logo_animation_player.play(&"show")
	GG.set_disabled_and_hide(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)

func _on_logo_animation_player_animation_finished(animation_name: StringName) -> void :

	if _fading_out_logo: return
	_fading_out_logo = true
	if _is_logo_unsynced: return

	var play_focus_music_seconds: float = logo_animation_player.get_animation(animation_name).length + logo_fade_out_duration
	logo_fade_out_duration = maxf(play_focus_music_seconds - _get_intro_music_seconds(), MIN_LOGO_FADE_OUT_SECONDS)

func _process(delta: float) -> void :
	if Engine.is_editor_hint(): return

	var now_usec: int = Time.get_ticks_usec()
	var frame_seconds: float = (now_usec - _last_frame_usec) / 1000000.0
	_last_frame_usec = now_usec
	_update_loading_label(frame_seconds)
	_sync_logo_to_music(delta, maxf(frame_seconds - delta, 0.0))
	_hold_logo_before_input_notice()
	if main_menu_buttons.visible != main_menu_additions.visible:
		GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	if not main_menu_buttons.visible or _fading_out_logo or logo_animation_player.is_playing():

		if logo_animation_player.is_playing()\
		and not loading_label.visible\
		and (Input.is_action_just_pressed(&"ui_accept")\
		or Input.is_action_just_pressed(&"ui_cancel")):
			_fading_out_logo = true
			_is_intro_skipped = true
			_is_input_notice_skipped = logo_animation_player.current_animation_position < INPUT_NOTICE_SECONDS
			logo_animation_player.speed_scale = skip_logo_animation_time_scale
			logo_fade_out_duration = skip_logo_fade_out_duration


		if _fading_out_logo and not _is_intro_skipped and not loading_label.visible and not _is_warm_up_done():
			_show_loading_label("intro ended")
		if _fading_out_logo and _can_reveal_menu():
			main_menu_buttons.visible = true
			gg_logo.modulate.a = move_toward(gg_logo.modulate.a, 0.0, frame_seconds / logo_fade_out_duration)
			if is_zero_approx(gg_logo.modulate.a):
				logo_animation_player.stop()
				GG.set_disabled_and_hide(gg_logo)
				GG.set_enabled_and_show(main_menu_buttons)
				GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
				#SoundBus.ignore_focus_sound(play_button)
				SoundBus.ignore_focus_sound(connect_button)
				#play_button.grab_focus()
				connect_button.grab_focus()
				InputManager.is_drawn_cursor_suppressed = false
				_fading_out_logo = false
				if _is_warm_up_done():
					set_process(false)

func _is_warm_up_done() -> bool:
	return ShaderCache.is_loaded and ParticlesCache.is_loaded


func _can_reveal_menu() -> bool:
	if _is_warm_up_done(): return true
	return _is_intro_skipped\
	and not loading_label.visible\
	and _get_warm_up_progress() >= SKIPPED_INTRO_MIN_WARM_UP_PROGRESS


func _update_loading_label(frame_seconds: float) -> void :
	if _is_warm_up_done():
		if loading_label.visible:
			loading_label.visible = false
			ParticlesCache.spread_warm_up = false
			GG.logt(GG.LogTag.UI, name, "Loading label hidden at", Time.get_ticks_msec())
		if not _fading_out_logo and not logo_animation_player.is_playing():
			set_process(false)
		return
	if loading_label.visible:
		_update_loading_progress()
		return
	var slow_frame_seconds: float = SKIPPED_INTRO_SLOW_FRAME_SECONDS if _is_intro_skipped else SLOW_FRAME_SECONDS
	if frame_seconds < slow_frame_seconds: return
	_slow_frames_count += 1
	if _slow_frames_count >= SLOW_FRAMES_TO_SHOW_LOADING:
		_show_loading_label("slow frames, last %.3f seconds" % frame_seconds)

func _show_loading_label(reason: String) -> void :
	loading_label.visible = true
	ParticlesCache.spread_warm_up = true
	_update_loading_progress()
	GG.logt(GG.LogTag.UI, name, "Loading label shown at", Time.get_ticks_msec(), reason)


func _update_loading_progress() -> void :
	loading_progress_bar.value = loading_progress_bar.max_value * _get_warm_up_progress()


func _get_warm_up_progress() -> float:
	var total_count: int = ShaderCache.get_total_count() + ParticlesCache.get_total_count()
	if total_count == 0: return 0.0
	var warmed_count: int = ShaderCache.get_warmed_count() + ParticlesCache.get_warmed_count()
	return float(warmed_count) / total_count


func _sync_logo_to_music(delta: float, clamped_seconds: float) -> void :
	if not logo_animation_player.is_playing(): return
	var music_seconds: float = _get_intro_music_seconds()
	var animation_position: float = logo_animation_player.current_animation_position
	var animation_length: float = logo_animation_player.current_animation_length

	var synced_position: float = minf(music_seconds - delta, animation_length)
	if loading_label.visible:

		logo_animation_player.speed_scale = 0.0
		var loading_frame: float = LOADING_LOGO_FRAMES[0]
		for index: int in LOADING_LOGO_FRAMES.size():

			if music_seconds >= LOADING_LOGO_FRAME_START_SECONDS[index]\
			or animation_position >= LOADING_LOGO_FRAMES[index] - 0.001:
				loading_frame = LOADING_LOGO_FRAMES[index]
		if not is_equal_approx(loading_frame, animation_position):
			logo_animation_player.seek(loading_frame, true)
		return
	if is_zero_approx(logo_animation_player.speed_scale):
		logo_animation_player.speed_scale = 1.0

		if music_seconds >= LOADING_LOGO_FRAME_START_SECONDS[1]:
			_is_logo_unsynced = true
			return

		if _is_in_logo_full_play_range(music_seconds):
			logo_animation_player.speed_scale = 0.0
			return
		logo_animation_player.seek(synced_position, true)
		return
	if _is_in_logo_full_play_range(animation_position):

		if clamped_seconds > 0.0:
			var real_time_position: float = animation_position + clamped_seconds * logo_animation_player.speed_scale
			logo_animation_player.seek(minf(real_time_position, animation_length), true)
		return
	if _is_logo_unsynced or is_inf(music_seconds): return
	for full_play_range: Vector2 in LOGO_FULL_PLAY_RANGES:
		if synced_position > full_play_range.x and synced_position < full_play_range.y:
			synced_position = full_play_range.x
	if synced_position > animation_position:
		logo_animation_player.seek(synced_position, true)



func _hold_logo_before_input_notice() -> void :
	if not _is_input_notice_skipped or not logo_animation_player.is_playing(): return
	var animation_position: float = logo_animation_player.current_animation_position
	if animation_position < SKIPPED_INTRO_LOGO_HOLD_SECONDS: return

	if animation_position >= INPUT_NOTICE_SECONDS:
		logo_animation_player.seek(SKIPPED_INTRO_LOGO_HOLD_SECONDS, true)
	logo_animation_player.pause()

func _is_in_logo_full_play_range(seconds: float) -> bool:
	for full_play_range: Vector2 in LOGO_FULL_PLAY_RANGES:
		if seconds >= full_play_range.x and seconds < full_play_range.y:
			return true
	return false


func _get_intro_music_seconds() -> float:
	if music.stream != music.intro or not music.playing: return INF
	return music.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

func _exit_tree() -> void :
	if Engine.is_editor_hint(): return
	InputManager.is_drawn_cursor_suppressed = false
	SoundBus.stop_all_audio()

func _on_connect_button_pressed() -> void:
	GG.set_disabled_and_hide(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	connect_menu.show_menu()
	connect_menu.closed.connect(_on_connect_menu_closed)

func _on_connect_menu_closed() -> void:
	connect_menu.closed.disconnect(_on_connect_menu_closed)
	# ArchipelagoMod.instance.disconnect()
	GG.set_enabled_and_show(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	RootMenu.grab_focus_prefer_hovered(main_menu_buttons, connect_button)

func _on_connect_menu_connection_established() -> void:
	pass

func _on_connect_menu_connection_failure(reason: String) -> void:
	message_popup.show_message("Connection to Archipelago failed:\n" + reason)

func _on_play_button_pressed() -> void :
	StartupProfiler.mark(&"main_menu_play_pressed")
	GG.set_disabled_and_hide(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	saves_menu.show_menu()
	saves_menu.closed.connect(on_saves_menu_closed_play_button)

func on_saves_menu_closed_play_button() -> void: # testing purposes
	saves_menu.closed.disconnect(on_saves_menu_closed_play_button)
	GG.set_enabled_and_show(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	RootMenu.grab_focus_prefer_hovered(main_menu_buttons, play_button)

func on_saves_menu_closed() -> void :
	saves_menu.closed.disconnect(on_saves_menu_closed)
	GG.set_enabled_and_show(connect_menu)

func _on_saves_menu_game_starting() -> void :

	var tween: Tween = create_tween()
	tween.tween_property(music, "volume_linear", 0.0, music_fade_out_duration)
	tween.tween_callback(music.stop)

func _on_settings_button_pressed() -> void :
	settings_menu.show_menu()

func on_settings_menu_shown() -> void :
	GG.set_disabled_and_hide(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	GG.safe_connect(settings_menu.closed, on_settings_menu_closed)

func on_settings_menu_closed() -> void :
	GG.safe_disconnect(settings_menu.closed, on_settings_menu_closed)
	GG.set_enabled_and_show(main_menu_buttons)
	GG.match_enabled_and_show(main_menu_additions, main_menu_buttons)
	RootMenu.grab_focus_prefer_hovered(main_menu_buttons, settings_button)

func _on_credits_button_pressed() -> void :
	load_scene(credits_scene)

func _on_quit_button_pressed() -> void :
	ScreenFader.set_hidden()
	await get_tree().process_frame
	await get_tree().process_frame
	GG.quit()

func load_scene(scene: String) -> void :
	if is_loading: return
	is_loading = true
	SoundBus.stop_all_audio()
	get_tree().change_scene_to_file(scene)

func _maybe_show_language_popup() -> void :
	if GameSettings.language != &"automatic": return
	if not GameSettings.system_locale: return
	language_select_popup.show_for_locale(GameSettings.system_locale)
	GG.safe_connect(language_select_popup.hidden, _on_language_popup_hidden)

func _on_language_popup_hidden() -> void :
	GG.safe_disconnect(language_select_popup.hidden, _on_language_popup_hidden)
	GameSettings.save()
	#SoundBus.ignore_focus_sound(play_button)
	SoundBus.ignore_focus_sound(connect_button)
	#play_button.grab_focus()
	connect_button.grab_focus()
