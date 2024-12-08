extends "res://scripts/prop_interact.gd"

@export var is_open := false

func _ready() -> void:
	show_curtain(is_open)

func show_curtain(open: bool) -> void:
	if open:
		$"StaticBody3D/House-window-curtain".hide()
		$"StaticBody3D/House-window-curtain-half".show()
	else:
		$"StaticBody3D/House-window-curtain".show()
		$"StaticBody3D/House-window-curtain-half".hide()

func player_interact(_player: Node3D) -> void:
	is_open = not is_open
	show_curtain(is_open)
