extends "res://scripts/prop_interact.gd"

@export var is_on := true
@export var on_offset := Vector3(0, 0, 0)
@export var off_offset := Vector3(0.1, 0, 0)
@export var on_range := 5
@export var off_range := 0
@export var invert_materials := false

@onready var start_origin = self.transform.origin
@onready var fuse_box := %FuseBox as Node3D

func _ready() -> void:
	print("starting light", is_on)
	for light in self.find_children("*", "MeshInstance3D"):
		set_light_materials(light, is_on)
		
func _process(_delta: float) -> void:
	if is_on and not fuse_box.has_power:
		toggle_position()
		toggle_groups()
		
func toggle_position():
	is_on = not is_on
	
	var on_origin = start_origin + on_offset
	var off_origin = start_origin + off_offset
	
	var dest_origin = on_origin
	if self.transform.origin == on_origin:
		dest_origin = off_origin
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", dest_origin, 0.25)
	tween.tween_callback(toggle_groups)
	
func toggle_groups() -> void:
	for group in self.get_groups():
		if "Lights" in group:
			print("toggle light group: ", group)
			toggle_lights(group)

func player_interact(player: Node3D) -> void:
	print("button script: ", self, ", player: ", player)
	toggle_position()


const LIGHT_MATERIAL_OFF := preload("res://materials/light-off.tres")
const LIGHT_MATERIAL_ON := preload("res://materials/light-on.tres")
const LIGHT_MATERIALS := [LIGHT_MATERIAL_OFF, LIGHT_MATERIAL_ON]

var light_status: Dictionary = {}

func set_light_materials(light: MeshInstance3D, status: bool) -> void:
	# TODO: only invert materials if this mesh is part of the button
	var should_invert := invert_materials
	if self.find_child(light.name) == null:
		should_invert = false
		
	var idx := 0
	while idx < light.get_surface_override_material_count():
		var material := light.get_surface_override_material(idx) as StandardMaterial3D
		if material in LIGHT_MATERIALS:
			if status:
				light.set_surface_override_material(idx, LIGHT_MATERIAL_OFF if should_invert else LIGHT_MATERIAL_ON)
			else:
				light.set_surface_override_material(idx, LIGHT_MATERIAL_ON if should_invert else LIGHT_MATERIAL_OFF)
				
		idx += 1

func toggle_lights(group: String) -> void:
	var nodes := get_tree().get_nodes_in_group(group)
	var prev_status: bool = light_status.get(group, true)
	var status := not prev_status
	
	if not fuse_box.has_power:
		print("fuse box does not have power")
	else:
		print("fuse box has power")
		
	status = status and fuse_box.has_power
	
	light_status[group] = status
	
	for light in nodes:
		if light is Node3D:
			nodes.append_array(light.get_children()) # tail recursion
			
		if light is OmniLight3D:
			if status:
				light.omni_range = on_range
			else:
				light.omni_range = off_range

		if light is MeshInstance3D:
			set_light_materials(light, status)
