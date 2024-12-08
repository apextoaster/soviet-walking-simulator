extends "res://scripts/prop_interact.gd"

const LIGHT_MATERIAL_OFF := preload("res://materials/tv-off.tres")
const LIGHT_MATERIAL_ON := preload("res://materials/tv-on.tres")
const LIGHT_MATERIALS := [LIGHT_MATERIAL_OFF, LIGHT_MATERIAL_ON]

@export var is_on := true
@export var on_energy := 1.2
@export var off_energy := 0

func set_light_materials(light: MeshInstance3D, status: bool) -> void:
	var idx := 0
	while idx < light.get_surface_override_material_count():
		var material := light.get_surface_override_material(idx) as StandardMaterial3D
		if material in LIGHT_MATERIALS:
			if status:
				light.set_surface_override_material(idx, LIGHT_MATERIAL_ON)
			else:
				light.set_surface_override_material(idx, LIGHT_MATERIAL_OFF)
				
		idx += 1

func toggle_lights() -> void:
	var nodes := self.get_children()
	is_on = not is_on
	
	for light in nodes:
		if light is Node3D:
			nodes.append_array(light.get_children()) # tail recursion
			
		if light is SpotLight3D:
			if is_on:
				light.light_energy = on_energy
			else:
				light.light_energy = off_energy

		if light is MeshInstance3D:
			set_light_materials(light, is_on)

func toggle_sound() -> void:
	if $RigidBody3D/AudioStreamPlayer3D.playing:
		# print("stopping tv sound")
		$RigidBody3D/AudioStreamPlayer3D.stop()
	else:
		# print("starting tv sound")
		$RigidBody3D/AudioStreamPlayer3D.play()

func player_interact(player: Node3D) -> void:
	print("tv script: ", self, ", player: ", player)
	toggle_lights()
	toggle_sound()

var remaining_time := 0.0

func _process(delta: float) -> void:
	remaining_time -= delta
	if remaining_time < 0:
		# set the light to a random color
		var color := Color.from_hsv(randf(), randf_range(0.2, 0.6), 1)
		$RigidBody3D/SpotLight3D.light_color = color
		remaining_time = randf_range(1, 10)
