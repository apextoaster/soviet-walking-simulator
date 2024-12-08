extends "res://scripts/prop_interact.gd"

@export var has_power := false

func _ready() -> void:
	show_sparks(has_power)

func show_sparks(powered: bool) -> void:
	if powered:
		$StaticBody3D/GPUParticles3D.show()
	else:
		$StaticBody3D/GPUParticles3D.hide()

func player_interact(_player: Node3D) -> void:
	print("toggling fuse box")
	has_power = not has_power
	show_sparks(has_power)
