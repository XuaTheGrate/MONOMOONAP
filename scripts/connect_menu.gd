@tool
class_name ConnectMenu
extends MenuBase

signal connection_established
signal connection_failure(reason: String)

func _ready() -> void :
	if Engine.is_editor_hint(): return
	super()

func show_menu() -> void :
	super()

func _on_connect_button_pressed() -> void:
	connection_failure.emit("Sample")
