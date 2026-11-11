extends Node
## Stage 1 gate for the Bellfold dawn graybox (PLAN.md): the whole route is
## playable start to end, every beat fires in order, every boundary holds, and
## the camera never clips into geometry or loses sight of the player.
##
## Run: godot --headless --path . res://tests/bellfold_route.tscn
## Exits with code 1 and prints FAIL on the first broken check.

const LEVEL_PATH: String = "res://game/levels/bellfold_dawn.tscn"
const REACH_RADIUS: float = 0.6
const WAYPOINT_TIMEOUT_FRAMES: int = 900
const CAMERA_CLEARANCE: float = 0.1
const PITCH_LIMITS_DEGREES: Array[float] = [-48.0, 12.0]
const SWEEP_DIRECTIONS: int = 16
const ESCAPE_DIRECTIONS: int = 32
const ESCAPE_PROBE_DISTANCE: float = 80.0
const ESCAPE_PROBE_LEG: float = 5.0
const FALL_LIMIT: float = -0.5
const EXPECTED_BEATS: Array[int] = [1, 2, 3, 4, 5]

var level: Node3D
var player: PlayerActor
var reached_beats: Array[int] = []
var failed: bool = false

func _ready() -> void:
	var scene: PackedScene = load(LEVEL_PATH) as PackedScene
	if not _expect(scene != null, "Missing level scene at %s." % LEVEL_PATH):
		return
	level = scene.instantiate() as Node3D
	add_child(level)
	level.connect("beat_reached", func(beat: int) -> void: reached_beats.append(beat))
	await _settle(3)
	player = level.get("player") as PlayerActor
	if not _expect(player != null, "The level must spawn a PlayerActor at runtime."):
		return
	var waypoints: Array[Vector3] = _route_waypoints()
	if not _expect(waypoints.size() >= 8, "Expected at least 8 route waypoints, got %d." % waypoints.size()):
		return
	await _walk_route(waypoints)
	if failed:
		return
	if not _expect(reached_beats == EXPECTED_BEATS, "Beats must fire in order %s, got %s." % [EXPECTED_BEATS, reached_beats]):
		return
	if not _expect(bool(level.get("route_complete")), "Reaching the end gate must complete the route."):
		return
	player.set_physics_process(false)
	var probe_points: Array[Vector3] = _with_midpoints(waypoints)
	_check_escape_probes(probe_points)
	_check_camera_sweeps(probe_points)
	if failed:
		return
	player.set_physics_process(true)
	await _check_push_against_vista_wall()
	if failed:
		return
	print("Bellfold dawn route, beats, boundaries, and camera passed.")
	get_tree().quit(0)

func _route_waypoints() -> Array[Vector3]:
	var points: Array[Vector3] = []
	var route: Node = level.get_node_or_null("Route")
	if route == null:
		return points
	for child: Node in route.get_children():
		if child is Marker3D:
			points.append((child as Marker3D).global_position)
	return points

func _with_midpoints(points: Array[Vector3]) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for index: int in range(points.size()):
		result.append(points[index])
		if index + 1 < points.size():
			result.append(points[index].lerp(points[index + 1], 0.5))
	return result

func _walk_route(waypoints: Array[Vector3]) -> void:
	Input.action_press("move_forward")
	for index: int in range(waypoints.size()):
		var reached: bool = await _walk_to(waypoints[index])
		if not _expect(reached, "Waypoint %d at %s not reached; player stuck at %s." % [index, waypoints[index], player.global_position]):
			break
	Input.action_release("move_forward")

func _walk_to(target: Vector3) -> bool:
	for frame: int in range(WAYPOINT_TIMEOUT_FRAMES):
		await get_tree().physics_frame
		var offset: Vector3 = target - player.global_position
		offset.y = 0.0
		# Check the camera as the player left it last frame, before steering
		# rotates the pivot; the player re-runs its clearance after any turn.
		var problem: String = _camera_problem()
		if not _expect(problem.is_empty(), "While walking to %s: %s" % [target, problem]):
			return false
		if player.global_position.y < FALL_LIMIT:
			_expect(false, "Player fell out of the level at %s." % player.global_position)
			return false
		if offset.length() <= REACH_RADIUS:
			return true
		player.camera_pivot.rotation.y = atan2(-offset.x, -offset.z)
	return false

func _check_escape_probes(points: Array[Vector3]) -> void:
	for point: Vector3 in points:
		if point.y > 0.5:
			continue
		for step: int in range(ESCAPE_DIRECTIONS):
			var angle: float = TAU * float(step) / float(ESCAPE_DIRECTIONS)
			var direction: Vector3 = Vector3(cos(angle), 0.0, sin(angle))
			if not _expect(_boundary_stops(point, direction), "No boundary stops the player leaving %s toward %s." % [point, direction]):
				return

## Sweeps the player's capsule from `start` along `direction` in short legs,
## because one 80 m motion test can miss a thin wall.
func _boundary_stops(start: Vector3, direction: Vector3) -> bool:
	player.global_position = start + Vector3(0.0, 0.1, 0.0)
	var travelled: float = 0.0
	while travelled < ESCAPE_PROBE_DISTANCE:
		if player.move_and_collide(direction * ESCAPE_PROBE_LEG, true) != null:
			return true
		player.global_position += direction * ESCAPE_PROBE_LEG
		travelled += ESCAPE_PROBE_LEG
	return false

func _check_camera_sweeps(points: Array[Vector3]) -> void:
	for point: Vector3 in points:
		player.global_position = point + Vector3(0.0, 0.05, 0.0)
		player.camera_pivot.global_position = player.global_position + Vector3(0.0, 1.35, 0.0)
		for pitch: float in PITCH_LIMITS_DEGREES:
			for step: int in range(SWEEP_DIRECTIONS):
				player.camera_pivot.rotation = Vector3(deg_to_rad(pitch), TAU * float(step) / float(SWEEP_DIRECTIONS), 0.0)
				player._update_camera_clearance()
				var problem: String = _camera_problem()
				if not _expect(problem.is_empty(), "Camera sweep at %s pitch %.0f yaw step %d: %s" % [point, pitch, step, problem]):
					return

func _camera_problem() -> String:
	var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	var camera_position: Vector3 = player.camera.global_position
	var pivot_position: Vector3 = player.camera_pivot.global_position
	var sight: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(pivot_position, camera_position)
	sight.exclude = [player.get_rid()]
	var blocked: Dictionary = space.intersect_ray(sight)
	if not blocked.is_empty():
		return "geometry %s blocks the camera at %s from the player." % [blocked.get("collider"), camera_position]
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = CAMERA_CLEARANCE
	var overlap: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	overlap.shape = sphere
	overlap.transform = Transform3D(Basis.IDENTITY, camera_position)
	overlap.exclude = [player.get_rid()]
	var touching: Array[Dictionary] = space.intersect_shape(overlap, 1)
	if not touching.is_empty():
		return "camera at %s is within %.2f m of %s." % [camera_position, CAMERA_CLEARANCE, touching[0].get("collider")]
	return ""

func _check_push_against_vista_wall() -> void:
	var overlook: Marker3D = level.get_node_or_null("Route/Waypoint03") as Marker3D
	if not _expect(overlook != null, "Route/Waypoint03 must mark the valley overlook."):
		return
	player.global_position = overlook.global_position + Vector3(0.0, 0.05, 0.0)
	player.velocity = Vector3.ZERO
	await _settle(2)
	Input.action_press("move_forward")
	for frame: int in range(150):
		await get_tree().physics_frame
		player.camera_pivot.rotation.y = -PI * 0.5
	Input.action_release("move_forward")
	var limit_x: float = float(level.get("overlook_wall_x"))
	_expect(player.global_position.y > FALL_LIMIT, "Pushing east at the overlook dropped the player to %s." % player.global_position)
	_expect(player.global_position.x < limit_x, "The overlook's low wall at x=%.1f must stop the player, who reached %s." % [limit_x, player.global_position])

func _settle(frames: int) -> void:
	for frame: int in range(frames):
		await get_tree().physics_frame

func _expect(condition: bool, message: String) -> bool:
	if condition or failed:
		return condition
	failed = true
	printerr("FAIL: %s" % message)
	get_tree().quit(1)
	return false
