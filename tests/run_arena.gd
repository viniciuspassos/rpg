extends Node

const PlayerScript = preload("res://game/actors/player.gd")
const KeyboardControls = preload("res://game/keyboard_controls.gd")
const VisualScene: PackedScene = preload("res://game/visual_mvp.tscn")

func _ready() -> void:
	KeyboardControls.install()
	var player: PlayerActor = PlayerScript.new() as PlayerActor
	player.arena_center = Vector2(0.0, 2.0)
	player.arena_radii = Vector2(5.0, 3.0)
	add_child(player)
	player.set_physics_process(false)
	player.position = Vector3(8.0, 0.1, 2.0)
	player.constrain_to_arena()
	assert(is_equal_approx(player.position.x, 5.0))
	assert(is_equal_approx(player.position.z, 2.0))
	player.position = Vector3(3.0, 0.1, 5.0)
	player.constrain_to_arena()
	var offset: Vector2 = Vector2(player.position.x, player.position.z) - player.arena_center
	assert(offset.x * offset.x / 25.0 + offset.y * offset.y / 9.0 <= 1.001)
	assert(is_equal_approx(player.position.y, 0.1))
	assert(player.get("walk_speed") == PlayerActor.WALK_SPEED, "The playable episode must retain its existing speed.")
	player.set("walk_speed", 1.2)
	player.position = Vector3(0.0, 0.1, 2.0)
	player.fixed_camera = true
	Input.action_press("move_right")
	player._physics_process(1.0 / 60.0)
	Input.action_release("move_right")
	assert(is_equal_approx(player.velocity.x, 1.2), "The visual scene must be able to use a walking pace.")
	var visual: Node3D = VisualScene.instantiate() as Node3D
	add_child(visual)
	var visual_player: PlayerActor = visual.find_child("ArenaPlayer", true, false) as PlayerActor
	assert(visual_player != null)
	assert(visual_player.arena_center == Vector2(-0.2, 1.75))
	assert(visual_player.arena_radii == Vector2(1.9, 1.35))
	assert(visual.find_child("ArenaPaving", true, false) != null)
	var barrier: StaticBody3D = visual.find_child("ArenaBarrier", true, false) as StaticBody3D
	assert(barrier != null)
	assert(barrier.get_child_count() >= 32)
	await get_tree().physics_frame
	for step: int in range(8):
		var angle: float = TAU * float(step) / 8.0
		var direction: Vector2 = Vector2(cos(angle), sin(angle))
		var origin: Vector2 = visual_player.arena_center + direction * 0.4
		var destination: Vector2 = visual_player.arena_center + direction * 3.0
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3(origin.x, 1.0, origin.y), Vector3(destination.x, 1.0, destination.y))
		var hit: Dictionary = visual.get_world_3d().direct_space_state.intersect_ray(query)
		assert(hit.get("collider") == barrier, "The arena barrier must close every side at standing height.")
	var visitor: CharacterBody3D = CharacterBody3D.new()
	var visitor_collision: CollisionShape3D = CollisionShape3D.new()
	var visitor_shape: CapsuleShape3D = CapsuleShape3D.new()
	visitor_shape.radius = 0.2
	visitor_shape.height = 0.8
	visitor_collision.shape = visitor_shape
	visitor.add_child(visitor_collision)
	visual.add_child(visitor)
	visitor.global_position = Vector3(0.8, 1.0, 1.75)
	for step: int in range(20):
		await get_tree().physics_frame
		visitor.velocity = Vector3(8.0, 0.0, 0.0)
		visitor.move_and_slide()
	assert(visitor.global_position.x < 1.6, "A 3D combatant must not cross the barrier.")
	print("Arena boundary passed.")
	get_tree().quit()
