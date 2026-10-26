extends RefCounted

static func install() -> void:
	_bind("move_left", KEY_A)
	_bind("move_right", KEY_D)
	_bind("move_forward", KEY_W)
	_bind("move_back", KEY_S)
	_bind("interact", KEY_E)
	_bind("attack", KEY_F)
	_bind("dodge", KEY_SPACE)
	_bind("power", KEY_Q)
	_bind("look_left", KEY_LEFT)
	_bind("look_right", KEY_RIGHT)
	_bind("look_up", KEY_UP)
	_bind("look_down", KEY_DOWN)

static func _bind(action_name: String, key: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action_name, event)
