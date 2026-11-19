@tool
class_name ConnectMenu
extends MenuBase

signal connection_success
signal connection_failure(reason: String)

func _ready() -> void :
	if Engine.is_editor_hint(): return
	
	ArchipelagoMod.instance.ap_ws_connected.connect(_on_ap_ws_connected)
	ArchipelagoMod.instance.ap_ws_connection_failure.connect(_on_ap_ws_connection_failure)
	super()

func show_menu() -> void :
	super()

func _on_ap_ws_connected() -> void:
	connection_success.emit()
	%ConnectButton.disabled = false
	%BackButton.disabled = false
	$SavingIcon.visible = false

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
