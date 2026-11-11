class_name BellfoldDawnLevel
extends Node3D
## Root of the linear v0 scene (PLAN.md, stage 1 graybox). It spawns the
## shared third-person PlayerActor at runtime and tracks the five beats in
## order through the Area3D nodes under BeatTriggers.
##
## Each trigger carries `metadata/beat` (1 to 5). RouteEnd closes the scene
## once the last beat has been reached. Usage:
##     var level: BellfoldDawnLevel = load("res://game/levels/bellfold_dawn.tscn").instantiate()
##     level.beat_reached.connect(func(beat: int) -> void: print(beat))

signal beat_reached(beat: int)
signal route_completed

const PlayerScript: GDScript = preload("res://game/actors/player.gd")
const KeyboardControls: GDScript = preload("res://game/keyboard_controls.gd")
const FINAL_BEAT: int = 5
## Flatter than the duel scenes' -22 degrees so the default view keeps the
## horizon and the vistas in frame along the road.
const CAMERA_TILT_DEGREES: float = -12.0

## X coordinate of the low wall at the valley overlook; tests push against it.
@export var overlook_wall_x: float = 11.0

var player: PlayerActor
var current_beat: int = 0
var route_complete: bool = false

func _ready() -> void:
	KeyboardControls.install()
	_spawn_player()
	_connect_beat_triggers()

## Advances to `beat` only when it is the next one, so walking back through an
## earlier trigger never rewinds the scene. Returns whether the beat advanced.
func reach_beat(beat: int) -> bool:
	if beat != current_beat + 1 or beat > FINAL_BEAT:
		return false
	current_beat = beat
	beat_reached.emit(beat)
	return true

func _spawn_player() -> void:
	var spawn: Marker3D = get_node("SpawnPoint") as Marker3D
	player = PlayerScript.new() as PlayerActor
	player.name = "Player"
	player.position = spawn.position
	player.rotation.y = spawn.rotation.y
	# Wide open levels must not reuse the old ring clamp from the duel scenes.
	player.arena_radii = Vector2.ZERO
	add_child(player)
	player.camera_pivot.rotation.y = spawn.rotation.y
	player.camera.rotation.x = deg_to_rad(CAMERA_TILT_DEGREES)

func _connect_beat_triggers() -> void:
	for trigger: Node in get_node("BeatTriggers").get_children():
		if not trigger is Area3D:
			continue
		var area: Area3D = trigger as Area3D
		if area.name == &"RouteEnd":
			area.body_entered.connect(_on_route_end_entered)
			continue
		var beat: int = int(area.get_meta("beat", 0))
		area.body_entered.connect(_on_beat_trigger_entered.bind(beat))

func _on_beat_trigger_entered(body: Node3D, beat: int) -> void:
	if body == player:
		reach_beat(beat)

func _on_route_end_entered(body: Node3D) -> void:
	if body != player or current_beat != FINAL_BEAT or route_complete:
		return
	route_complete = true
	route_completed.emit()
