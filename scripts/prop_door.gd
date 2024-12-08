extends "res://scripts/prop_interact.gd"

@export var is_closed := true
@export var is_locked := false
@export var closed_angle := 0.0
@export var open_angle := 90.0

func _ready() -> void:
	print("starting door", self.rotation_degrees.y, is_closed)
	set_angle(is_closed, 0)
			
func set_angle(closed: bool, duration: float = 1.0) -> void:
	is_closed = closed
	
	var dest_angle := closed_angle
	if is_closed:
		dest_angle = deg_to_rad(closed_angle)
	else:
		dest_angle = deg_to_rad(open_angle)
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", Vector3(0, dest_angle, 0), duration)

func toggle_angle() -> void:
	set_angle(not is_closed)

func player_interact(player: Node3D) -> void:
	print("door script: ", self, ", player: ", player)
	$AudioStreamPlayer3D.play()
	if not is_locked:
		toggle_angle()
