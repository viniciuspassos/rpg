extends Node

const VisualScene: PackedScene = preload("res://game/visual_mvp.tscn")
var _failed: bool = false

func _ready() -> void:
	get_window().size = Vector2i(1440, 810)
	var scene: Node3D = VisualScene.instantiate() as Node3D
	add_child(scene)
	_test_opponent_layer(scene)
	var actor: PlayerActor = get_tree().get_first_node_in_group("player") as PlayerActor
	actor.set_physics_process(false)
	_test_spawn_inside_arena(actor)
	_test_duel_space(actor)
	var presentation: Node3D = scene.get_node_or_null("IllustratedProtagonist") as Node3D
	if presentation == null:
		push_error("The scene needs an illustrated movement presentation.")
		get_tree().quit(1)
		return
	presentation.set_physics_process(false)
	var sprite: Sprite3D = presentation.get_node("Sprite") as Sprite3D
	_test_walk_poses(presentation, sprite)
	_test_back_walk(presentation, sprite)
	_test_facing(presentation, sprite)
	_test_ground_anchor(actor, presentation, sprite)
	_test_blocked_facing(actor, presentation, sprite)
	await get_tree().process_frame
	if not _test_framing(scene, actor, presentation, sprite) or _failed:
		get_tree().quit(1)
		return
	print("Illustrated poses, direction, grounding, and arena framing passed.")
	get_tree().quit()

func _test_opponent_layer(scene: Node3D) -> void:
	var backdrop: TextureRect = scene.get_node_or_null("Backdrop/Plate") as TextureRect
	var opponent: TextureRect = scene.get_node_or_null("Opponent/StaticPose") as TextureRect
	_check(backdrop != null and opponent != null, "The opponent must have a separate image layer.")
	if backdrop == null or opponent == null:
		return
	_check(backdrop.texture.resource_path.ends_with("village_duel_empty.png"), "The background must contain no baked opponent.")
	_check(opponent.texture.resource_path.ends_with("opponent_static.png"), "The opponent must use an independent transparent asset.")

func _test_walk_poses(presentation: Node3D, sprite: Sprite3D) -> void:
	presentation.call("update_motion", Vector3(0.05, 0.0, 0.0))
	_check(sprite.frame_coords.x == 1, "Movement must start a step.")
	presentation.call("update_motion", Vector3(0.22, 0.0, 0.0))
	_check(sprite.frame_coords.x == 0, "Feet must pass between strides.")
	presentation.call("update_motion", Vector3(0.22, 0.0, 0.0))
	_check(sprite.frame_coords.x == 2, "The next stride must alternate feet.")
	presentation.call("update_motion", Vector3.ZERO)
	_check(sprite.frame_coords.x == 0, "A stopped or blocked actor must return to idle.")
	_check(sprite.frame_coords.y == 3, "Stopping must retain the last facing.")

func _test_spawn_inside_arena(actor: PlayerActor) -> void:
	_check(_arena_contains(actor, Vector2(actor.position.x, actor.position.z)), "The visual spawn must be inside the walk area without an opening-frame correction.")

func _test_duel_space(actor: PlayerActor) -> void:
	_check(_arena_contains(actor, Vector2(-1.2, actor.arena_center.y)), "The left paving must remain available for the duel.")
	_check(_arena_contains(actor, Vector2(1.0, actor.arena_center.y)), "The protagonist must be able to approach the opponent.")
	_check(not _arena_contains(actor, Vector2(2.2, actor.arena_center.y)), "The arena must stop before the foreground props.")

func _arena_contains(actor: PlayerActor, point: Vector2) -> bool:
	var offset: Vector2 = point - actor.arena_center
	var normalized: Vector2 = Vector2(offset.x / actor.arena_radii.x, offset.y / actor.arena_radii.y)
	return normalized.length_squared() <= 1.0

func _test_back_walk(presentation: Node3D, sprite: Sprite3D) -> void:
	presentation.call("update_motion", Vector3.FORWARD * 0.05)
	_check(sprite.frame_coords == Vector2i(1, 0), "Walking toward the scene must begin with a stride.")
	presentation.call("update_motion", Vector3.FORWARD * 0.22)
	_check(sprite.frame_coords == Vector2i(3, 0), "The back walk must pass through a neutral step, not the ready pose.")
	presentation.call("update_motion", Vector3.ZERO)
	_check(sprite.frame_coords == Vector2i(0, 0), "Stopping toward the scene must restore the approved ready pose.")

func _test_facing(presentation: Node3D, sprite: Sprite3D) -> void:
	var directions: Array[Vector3] = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	for row: int in range(directions.size()):
		presentation.call("update_motion", directions[row] * 0.05)
		_check(sprite.frame_coords.y == row, "The drawing must face the travel direction.")

func _test_ground_anchor(actor: PlayerActor, presentation: Node3D, sprite: Sprite3D) -> void:
	actor.position = Vector3(0.3, 0.0, 2.2)
	actor.rotation.y = PI * 0.5
	presentation.call("_physics_process", 1.0 / 60.0)
	_check(is_equal_approx(presentation.global_position.x, actor.global_position.x), "The image must follow the actor laterally.")
	_check(is_equal_approx(presentation.global_position.z, actor.global_position.z + IllustratedProtagonist.VISUAL_DEPTH), "The image must keep its depth offset.")
	_check(presentation.global_rotation.is_zero_approx(), "Turning must not orbit the image or shadow around the actor.")
	_check(absf(sprite.position.y - 180.0 * sprite.pixel_size) < 0.001, "The atlas foot baseline must meet the ground.")

func _test_blocked_facing(actor: PlayerActor, presentation: Node3D, sprite: Sprite3D) -> void:
	presentation.call("update_motion", Vector3(0.05, 0.0, 0.0))
	actor.velocity = Vector3.ZERO
	actor.position.z -= 0.03
	presentation.call("_physics_process", 1.0 / 60.0)
	_check(sprite.frame_coords == Vector2i(0, 3), "Arena correction must not turn a blocked protagonist away from her last facing.")

func _test_framing(scene: Node3D, actor: PlayerActor, presentation: Node3D, sprite: Sprite3D) -> bool:
	var camera: Camera3D = scene.get_node("FixedCamera") as Camera3D
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var safe_area: Rect2 = Rect2(Vector2(18.0, 18.0), viewport_size - Vector2(36.0, 36.0))
	var outline: Array[Vector2i] = _atlas_outline(sprite.texture.get_image())
	if outline.is_empty():
		push_error("The motion atlas must contain visible poses.")
		return false
	for sample: int in range(32):
		var angle: float = TAU * float(sample) / 32.0
		var reach: Vector2 = actor.arena_radii - Vector2(0.42, 0.42)
		actor.position = Vector3(actor.arena_center.x + cos(angle) * reach.x, 0.0, actor.arena_center.y + sin(angle) * reach.y)
		presentation.call("_physics_process", 1.0 / 60.0)
		for pixel: Vector2i in outline:
			var local: Vector3 = Vector3(float(pixel.x - 200) * sprite.pixel_size, float(200 - pixel.y) * sprite.pixel_size + sprite.position.y, 0.0)
			var point: Vector2 = camera.unproject_position(presentation.global_position + local)
			if not safe_area.has_point(point):
				push_error("Pose clips at arena sample %d: frame pixel %s projects to %s" % [sample, pixel, point])
				return false
	return true

func _atlas_outline(atlas: Image) -> Array[Vector2i]:
	var outline: Array[Vector2i] = []
	for frame: int in range(16):
		var frame_origin: Vector2i = Vector2i(frame % 4, frame / 4) * 400
		var bounds: Rect2i = atlas.get_region(Rect2i(frame_origin, Vector2i(400, 400))).get_used_rect()
		if bounds.has_area():
			outline.append(bounds.position)
			outline.append(bounds.position + Vector2i(bounds.size.x, 0))
			outline.append(bounds.end)
			outline.append(bounds.position + Vector2i(0, bounds.size.y))
	return outline

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
