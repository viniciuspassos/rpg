extends Node

const GuardScript = preload("res://game/actors/guard.gd")

func _ready() -> void:
	var guard: GuardActor = GuardScript.new() as GuardActor
	var defeats: Array[int] = [0]
	guard.defeated.connect(func() -> void: defeats[0] += 1)
	add_child(guard)
	assert(guard.health == 68)
	guard.take_damage(34)
	assert(guard.health == 34)
	guard.take_damage(34)
	assert(guard.health == 0)
	assert(defeats[0] == 1)
	print("Short encounter combat passed.")
	get_tree().quit()
