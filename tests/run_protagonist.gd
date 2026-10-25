extends Node

const PlayerScript = preload("res://game/actors/player.gd")

func _ready() -> void:
	var player: PlayerActor = PlayerScript.new() as PlayerActor
	add_child(player)
	player.set_physics_process(false)
	var model: Node3D = player.get_node("Protagonist") as Node3D
	assert(model != null)
	assert(is_equal_approx(model.rotation.y, PI))
	assert(model.find_child("Leg_L", true, false) != null)
	assert(model.find_child("Leg_R", true, false) != null)
	assert(model.find_child("Arm_R", true, false) != null)
	assert(player.weapon_rig == model.find_child("Arm_L", true, false))
	assert(player.weapon_rig.find_child("tapered sword blade", true, false) != null)
	assert(model.find_child("cloak tail", true, false) != null)
	player.animate_protagonist(0.1, 1.0)
	var left_leg: Node3D = model.find_child("Leg_L", true, false) as Node3D
	assert(absf(left_leg.rotation.x) > 0.01)
	player.animate_protagonist(0.1, 0.0)
	assert(absf(left_leg.rotation.x) < 0.5)
	player.set_protagonist_presentation("male")
	var bun: Node3D = model.find_child("low bun", true, false) as Node3D
	assert(not bun.visible)
	var tail: MeshInstance3D = model.find_child("cloak tail", true, false) as MeshInstance3D
	assert(tail.material_override != null)
	player.set_protagonist_presentation("female")
	assert(bun.visible)
	assert(tail.material_override == null)
	player.animate_protagonist(0.1, 1.0)
	player.reset_for_fresh_run()
	assert(is_zero_approx(left_leg.rotation.x))
	assert(is_zero_approx(player.weapon_rig.rotation.x))
	assert(is_zero_approx(model.position.y))
	print("Protagonist model and walk animation passed.")
	get_tree().quit()
