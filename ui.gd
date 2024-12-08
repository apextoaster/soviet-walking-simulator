extends Control

enum ControlScheme {
	Keyboard,
	Gamepad,
}

@export var control_scheme: String = "keyboard"
@export var show_controls: bool = true

func switch_control_scheme(scheme: String) -> void:
	control_scheme = scheme
	if not show_controls:
		$GamepadControls.hide()
		$KeyboardControls.hide()
		return
		
	if scheme == "keyboard":
		$GamepadControls.hide()
		$KeyboardControls.show()
	elif scheme == "gamepad":
		$GamepadControls.show()
		$KeyboardControls.hide()
