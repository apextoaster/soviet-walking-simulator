extends Node3D

@export var always_update := false
@export var interaction_distance := 5
@export var interaction_tooltip := "Anonymous Prop"
@export var interaction_impulse := 0.0
@export var physics_body: PhysicsBody3D = null # self.get_child(0)

signal player_interaction(node: Node3D, body: PhysicsBody3D, event: InputEvent, event_position: Vector3, normal: Vector3)
signal hover_start(node: Node3D, body: PhysicsBody3D)
signal hover_leave(node: Node3D, body: PhysicsBody3D)

func _on_rigid_body_3d_input_event(_camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, _shape_idx: int) -> void:
	player_interaction.emit(self, self.get_child(0), event, event_position, normal)

func _on_physics_body_3d_mouse_entered() -> void:
	hover_start.emit(self, self.get_child(0))

func _on_physics_body_3d_mouse_exited() -> void:
	hover_leave.emit(self, self.get_child(0))

func player_interact(player: Node3D) -> void:
	print("base prop script: ", self, ", player: ", player)
	if interaction_impulse != 0 and physics_body != null:
		# add a physics impulse in the direction away from the player, as if the item was kicked
		var pivot := player.get_child(0)
		var diff := player.global_position - physics_body.global_position
		# var direction: Vector3 = player.get_ray_vector() * interaction_impulse
		var direction := Vector3(0, 1, 0)
		print("applying impulse: ", direction, " from ", diff)
		physics_body.apply_impulse(direction, diff) 
