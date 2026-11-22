@tool
class_name ConnectMenu
extends MenuBase

signal connection_success
signal connection_failure(reason: String)

var _preferences: Preferences

func _ready() -> void :
	if Engine.is_editor_hint(): return
	
	ArchipelagoMod.instance.ap_ws_connected.connect(_on_ap_ws_connected)
	ArchipelagoMod.instance.ap_ws_connection_failure.connect(_on_ap_ws_connection_failure)
	_preferences = Preferences.load()
	super()

func show_menu() -> void :
	%AddressInput.text = _preferences.address
	%PortInput.text = _preferences.port
	%SlotInput.text = _preferences.slot
	%PasswordInput.text = _preferences.password
	super()

func _on_ap_ws_connected() -> void:
	connection_success.emit()
	%ConnectButton.disabled = false
	%BackButton.disabled = false
	$SavingIcon.visible = false
	
	_preferences.address = %AddressInput.text
	_preferences.port = %PortInput.text
	_preferences.slot = %SlotInput.text
	_preferences.password = %PasswordInput.text
	_preferences.save()

func _on_ap_ws_connection_failure(reason: String) -> void:
	connection_failure.emit(reason)
	%ConnectButton.disabled = false
	%BackButton.disabled = false
	$SavingIcon.visible = false

func _on_connect_button_pressed() -> void:
	%ConnectButton.disabled = true
	%BackButton.disabled = true
	$SavingIcon.visible = true
	ArchipelagoMod.instance.connect_to_ap(
		%AddressInput.text,
		%PortInput.text,
		%SlotInput.text,
		%PasswordInput.text
	)
