extends SceneTree

const KeyboardControls = preload("res://game/keyboard_controls.gd")

func _initialize() -> void:
	KeyboardControls.install()
	_assert_key_action("attack", KEY_F)
	_assert_key_action("look_left", KEY_LEFT)
	_assert_key_action("look_right", KEY_RIGHT)
	_assert_key_action("look_up", KEY_UP)
	_assert_key_action("look_down", KEY_DOWN)
	for action: String in ["move_left", "move_right", "move_forward", "move_back", "interact", "dodge", "power", "attack", "look_left", "look_right", "look_up", "look_down"]:
		for event: InputEvent in InputMap.action_get_events(action):
			assert(not event is InputEventMouse)
	print("Keyboard-only input passed.")
	quit()

func _assert_key_action(action: String, key: Key) -> void:
	var found: bool = false
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == key:
			found = true
	assert(found, "Missing keyboard mapping for %s" % action)
