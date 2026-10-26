extends Node

const PlayerScript = preload("res://game/actors/player.gd")
const KeyboardControls = preload("res://game/keyboard_controls.gd")

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
	print("Arena boundary passed.")
	get_tree().quit()
