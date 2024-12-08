extends "res://scripts/prop_interact.gd"

@export var interaction_tooltip_format := "Clock\n%02d:%02d"

@onready var _world_env := %WorldEnvironment as WorldEnvironment

var active := false
var hour: int = 0
var minute: int = 0

func update_tooltip() -> void:
	var time: float = _world_env.time
	hour = floor(time * 24)
	minute = floor(((time * 24) - hour) * 60)
	
	var tooltip := interaction_tooltip_format % [hour, minute]
	if tooltip != interaction_tooltip:
		# print("updating tooltip: ", interaction_tooltip)
		interaction_tooltip = tooltip
		
		if active: # update the tooltip in the UI
			hover_start.emit(self, self.get_child(0), true) 

func _process(_delta: float) -> void:
	update_tooltip()

func _on_physics_body_3d_mouse_entered() -> void:
	active = true
	update_tooltip()

func _on_physics_body_3d_mouse_exited() -> void:
	active = false
	hover_leave.emit(self, self.get_child(0))
