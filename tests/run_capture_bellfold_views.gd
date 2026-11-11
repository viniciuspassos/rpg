extends Node
## Gate captures and frame-rate sampling for the Bellfold dawn scene. Needs a
## window (the headless renderer returns blank images).
##
## Captures: godot --path . res://tests/capture_bellfold_views.tscn -- --capture-dir=/abs/dir
## FPS:      godot --path . res://tests/capture_bellfold_views.tscn -- --measure-fps
## Put `--atmosphere` (volumetric fog, SSAO, glow) or `--supersample` (2x 3D
## resolution) before `--measure-fps` to price the look stage.
## Add `--rendering-method forward_plus` before `--` to compare renderers.

const LEVEL_PATH: String = "res://game/levels/bellfold_dawn.tscn"
const SETTLE_FRAMES: int = 20
const REACH_RADIUS: float = 0.6
const WAYPOINT_TIMEOUT_SECONDS: float = 20.0

## name: [player position, point the camera looks toward, pivot pitch in degrees]
const VIEWS: Dictionary = {
	"01_spawn_road": [Vector3(0, 0.05, 0), Vector3(0, 0, -30), 0.0],
	"02_overlook_valley": [Vector3(7, 0.05, -36), Vector3(60, 0, -40), 2.0],
	"03_road_to_village": [Vector3(6, 0.05, -40), Vector3(16.6, 0, -76.5), 0.0],
	"04_square_entry": [Vector3(3, 0.05, -68), Vector3(16.6, 0, -77), 0.0],
	"05_duel": [Vector3(3, 0.05, -77.5), Vector3(16.6, 0, -76.5), 0.0],
	"06_exit_road": [Vector3(6, 0.05, -97), Vector3(6, 0, -112), 0.0],
}

var level: BellfoldDawnLevel
var player: PlayerActor

func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	level = (load(LEVEL_PATH) as PackedScene).instantiate() as BellfoldDawnLevel
	add_child(level)
	player = level.player
	await _frames(SETTLE_FRAMES)
	for arg: String in args:
		if arg.begins_with("--capture-dir="):
			await _capture_views(arg.trim_prefix("--capture-dir="))
		elif arg == "--supersample":
			get_viewport().scaling_3d_scale = 2.0
		elif arg == "--atmosphere":
			_enable_atmosphere()
		elif arg == "--measure-fps":
			await _measure_route_fps()
	get_tree().quit()

func _capture_views(directory: String) -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	player.set_physics_process(false)
	for view_name: String in VIEWS:
		var view: Array = VIEWS[view_name]
		_place_camera(view[0], view[1], view[2])
		await _frames(SETTLE_FRAMES)
		var image: Image = get_viewport().get_texture().get_image()
		var path: String = directory.path_join("%s.png" % view_name)
		image.save_png(path)
		print("Saved %s (%dx%d)" % [path, image.get_width(), image.get_height()])
	player.set_physics_process(true)

func _place_camera(position: Vector3, look_toward: Vector3, pitch_degrees: float) -> void:
	var offset: Vector3 = look_toward - position
	var yaw: float = atan2(-offset.x, -offset.z)
	player.global_position = position
	player.rotation.y = yaw
	player.camera_pivot.global_position = position + Vector3(0, 1.35, 0)
	player.camera_pivot.rotation = Vector3(deg_to_rad(pitch_degrees), yaw, 0)
	player._update_camera_clearance()

## Walks the whole route with vsync off and prints frame timings. Metal holds
## Forward+ at the display rate even with vsync off, so compare renderers by
## whether they keep 60 fps under `--supersample` as well.
func _measure_route_fps() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var frame_times: Array[float] = []
	Input.action_press("move_forward")
	for waypoint: Node in level.get_node("Route").get_children():
		var target: Vector3 = (waypoint as Marker3D).global_position
		var elapsed: float = 0.0
		while elapsed < WAYPOINT_TIMEOUT_SECONDS and not _steer_toward(target):
			await get_tree().process_frame
			frame_times.append(get_process_delta_time())
			elapsed += get_process_delta_time()
	Input.action_release("move_forward")
	_print_timing_summary(frame_times)

## Points the camera at `target`; returns true once the player is there.
func _steer_toward(target: Vector3) -> bool:
	var offset: Vector3 = target - player.global_position
	offset.y = 0.0
	if offset.length() <= REACH_RADIUS:
		return true
	player.camera_pivot.rotation.y = atan2(-offset.x, -offset.z)
	return false

## Turns on the Forward+ atmosphere the look stage wants (Compatibility
## ignores what it does not support), to price it before committing.
func _enable_atmosphere() -> void:
	var environment: Environment = (level.get_node("WorldEnvironment") as WorldEnvironment).environment
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.01
	environment.ssao_enabled = true
	environment.glow_enabled = true

func _print_timing_summary(frame_times: Array[float]) -> void:
	var summary: Dictionary = {
		"renderer": RenderingServer.get_current_rendering_method(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"frames": frame_times.size(),
		"average_fps": snappedf(1.0 / _average(frame_times), 0.1),
		"one_percent_low_fps": snappedf(1.0 / _percentile(frame_times, 0.99), 0.1),
		"scaling_3d_scale": get_viewport().scaling_3d_scale,
		"atmosphere": (level.get_node("WorldEnvironment") as WorldEnvironment).environment.ssao_enabled,
		"route_complete": level.route_complete,
	}
	print(JSON.stringify(summary))

func _average(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / maxf(float(values.size()), 1.0)

func _percentile(values: Array[float], fraction: float) -> float:
	var sorted_values: Array[float] = values.duplicate()
	sorted_values.sort()
	return sorted_values[mini(int(float(sorted_values.size()) * fraction), sorted_values.size() - 1)]

func _frames(count: int) -> void:
	for frame: int in range(count):
		await get_tree().process_frame
