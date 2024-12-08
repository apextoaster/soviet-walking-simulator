#extends CharacterBody3D
extends IKCC

const WALK_SPEED = 3.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5
const DEFAULT_TEXT = "+"

# @onready var _camera := %PlayerCamera as Camera3D
@onready var _camera_pivot := %CameraPivot as Node3D
@onready var tree := get_tree()
@onready var raycast := $CameraPivot/SpringArm3D/Camera3D/RayCast3D

@export_range(0.0, 1.0) var mouse_sensitivity := 0.01
var current_target: Node3D = null
var current_body: Node3D = null
var mute := false
var was_action_pressed := false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor: # ():
		velocity += get_gravity() * delta
	else:
		# Handle jump.
		if Input.is_action_just_pressed("Move Jump") and is_on_floor: # ():
			velocity.y = JUMP_VELOCITY
			
		var running := Input.is_action_pressed("Move Run")
		var speed := RUN_SPEED if running else WALK_SPEED

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("Move Backward", "Move Forward", "Move Left", "Move Right")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
	var input_rot := Input.get_vector("Turn Left", "Turn Right", "Look Up", "Look Down")
	var r := (transform.basis * Vector3(0, -input_rot.x, 0)).normalized()
	rotation_degrees += r

	move_and_slide()
	
	#for col_idx in collision_count: # get_slide_collision_count():
	#	var col := get_slide_collision(col_idx)
	#	if col.get_collider() is RigidBody3D:
	#		col.get_collider().apply_impulse(-col.get_normal() * 100 * delta, col.get_position() - col.get_collider().global_position)
	
	var c := check_ray_intersection()
	var c_parent = null
	var always_update := false
	if c != null:
		c_parent = c.get_parent_node_3d()
		var parent_update = c_parent.get("always_update")
		if parent_update != null:
			always_update = parent_update
		
	if always_update or c != current_body:
		# print("setting intersection target", c)
		if c_parent != null and c_parent.has_method("player_interact"):
			_on_prop_hover_start(c_parent, c, always_update)
		else:
			_on_prop_hover_leave(null, null)

func _ready() -> void:
	raycast.add_exception(self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		if event is InputEventKey:
			%UI.switch_control_scheme("keyboard")
		if event is InputEventJoypadButton:
			%UI.switch_control_scheme("gamepad")
			
		if Input.is_action_just_pressed("Action Select"):
			print("interacting with prop: ", current_target, current_body)
			if current_target and current_body:
				_on_prop_player_interaction(current_target, current_body, event, Vector3(0, 0, 0), Vector3(0, 0, 0))
		else:
			was_action_pressed = false
			
		if Input.is_action_just_pressed("Toggle Controls"):
			print("toggling controls")
			%UI.show_controls = not %UI.show_controls
		
		if Input.is_action_just_pressed("Toggle Pause"):
			print("pausing game")
			tree.paused = not tree.paused
			
		if Input.is_action_just_pressed("Toggle Sound"):
			print("toggling sound")
			mute = not mute
			var bus_idx := AudioServer.get_bus_index("Master")
			AudioServer.set_bus_mute(bus_idx, mute)
			
		if Input.is_action_just_pressed("Reset Position"):
			print("reset position")
			global_position = %PlayerStart.global_position
			
		if Input.is_action_just_pressed("Exit"):
			print("exiting game")
			tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			tree.quit()
		
	if event is InputEventMouseMotion and not tree.paused:
		%UI.switch_control_scheme("keyboard")
		# horizontal
		var dest_y: float = _camera_pivot.rotation.y + (-event.relative.x * mouse_sensitivity)
		var clamped_y := clampf(dest_y, deg_to_rad(-150), deg_to_rad(-30))
		_camera_pivot.rotation.y = clamped_y
		
		# turn the overflow into rotation of the player body
		if dest_y != clamped_y:
			var diff_y := dest_y - clamped_y
			var r := (transform.basis * Vector3(0, diff_y * 2, 0)).normalized()
			rotation_degrees += r
		
		# vertical
		_camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, deg_to_rad(-55), deg_to_rad(45))
		
	if event is InputEventJoypadMotion and not tree.paused:
		%UI.switch_control_scheme("gamepad")
		var look := Input.get_vector("Look Right", "Look Left", "Look Down", "Look Up")
		# print("joypad motion: ", look, event)
		rotation_degrees += Vector3(0, look.x, 0)
		_camera_pivot.rotation.x += look.y * mouse_sensitivity
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, deg_to_rad(-55), deg_to_rad(45))

func is_interact_pressed() -> bool:
	var pressed := Input.is_action_pressed("Action Select")
	var new_press := pressed and not was_action_pressed
	was_action_pressed = pressed
	return new_press
	
func is_valid_interaction(prop: Node3D, body: PhysicsBody3D) -> bool:
	# check if the interact button was pressed and the target is within range
	if is_interact_pressed():
		return check_interaction_distance(prop, body)
	else:
		return false
		
func check_interaction_distance(prop: Node3D, body: PhysicsBody3D) -> bool:
	var diff := self.global_position - body.global_position
	var dist := diff.length()
	print("interaction distance: ", dist, " vs ", prop.interaction_distance, " from ", body.global_position)
	return (dist < prop.interaction_distance)
	
func check_ray_intersection() -> Node3D:
	# raycast.force_raycast_update()
	if raycast.is_colliding():
		return raycast.get_collider()
		
	return null

func get_ray_vector() -> Vector3:
	return $CameraPivot/SpringArm3D/Camera3D/RayCast3D.global_rotation * $CameraPivot/SpringArm3D/Camera3D/RayCast3D.target_position

func _on_prop_player_interaction(prop: Node3D, body: PhysicsBody3D, _event: InputEvent, _event_position: Vector3, _normal: Vector3) -> void:
	if is_valid_interaction(prop, body):
		print("interacted with prop: ", prop, ", physics body: ", body)
		if prop.has_method("player_interact"):
			prop.player_interact(self)

func set_focus(prop: Node3D, body: PhysicsBody3D, always_update: bool = false) -> void:
	if always_update or prop != current_target:
		var prop_name: String = DEFAULT_TEXT
		if prop != null and check_interaction_distance(prop, body):
			var prop_tooltip: String = prop.get("interaction_tooltip")
			if prop_tooltip == null:
				prop_name = prop.name
			else:
				if EngineDebugger.is_active():
					prop_name = "%s (%s)" % [prop_tooltip, prop.name]
				else:
					prop_name = prop_tooltip
				
			print("setting focus to: ", prop_name)
			%Label.text = prop_name
			current_target = prop
			current_body = body
		else:
			print("clearing focus")
			%Label.text = DEFAULT_TEXT
			current_target = null
			current_body = null

func _on_prop_hover_start(prop: Node3D, body: PhysicsBody3D, always_update: bool = false) -> void:
	set_focus(prop, body, always_update)
	
func _on_prop_hover_leave(_prop: Node3D, _body: PhysicsBody3D) -> void:
	set_focus(null, null)

func _on_button_player_interaction(prop: Node3D, body: PhysicsBody3D, event: InputEvent, _event_position: Vector3, _normal: Vector3) -> void:
	set_focus(prop, body)
	if is_valid_interaction(prop, body):
		print("player interacted with button", prop, event)
		prop.player_interact(self)

func _on_dumpster_player_interaction(prop: Node3D, body: PhysicsBody3D, _event: InputEvent, _event_position: Vector3, _normal: Vector3) -> void:
	set_focus(prop, body)
	if is_valid_interaction(prop, body):
		print("player interacted with dumpster") 
		prop.player_interact(self)

func _on_door_player_interaction(prop: Node3D, body: PhysicsBody3D, _event: InputEvent, _event_position: Vector3, _normal: Vector3) -> void:
	set_focus(prop, body)
	if is_valid_interaction(prop, body):
		print("player interacted with door")
		prop.player_interact(self)
