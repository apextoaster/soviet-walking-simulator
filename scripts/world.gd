extends WorldEnvironment

@export_range(0, 1.0) var time := 1.0
@export var time_scale := 10 / 1000.0 # milliseconds per minute
@export var run_time := true
@export var sky_gradient := preload("res://materials/sky_gradient.tres")
@export var ambient_gradient := preload("res://materials/ambient_gradient.tres")

func _ready() -> void:
	set_sky_time()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Toggle Time"):
		print("toggling time")
		run_time = not run_time
		
	if run_time:
		var prev_time := time
		time += delta * time_scale
		time -= floor(time)
		if time != prev_time:
			set_sky_time()

func set_sky_time() -> void:
	var sky_shader: ShaderMaterial = self.environment.sky.sky_material
	var sky_mix := sky_gradient.sample(time).r
	# print("setting sky: ", sky_mix, ", ", time)
	sky_shader.set_shader_parameter("time", sky_mix)
	
	self.environment.ambient_light_color = ambient_gradient.sample(time)
