class_name IllustratedProtagonist
extends Node3D

const ATLAS: Texture2D = preload("res://game/art/protagonist_motion.png")
const PIXEL_SIZE: float = 0.0064
const FOOT_BASELINE: float = 180.0
const FRAME_DISTANCE: float = 0.22
const VISUAL_DEPTH: float = 0.5
const WALK_POSES: Array[int] = [1, 0, 2, 0]
const BACK_WALK_POSES: Array[int] = [1, 3, 2, 3]

var actor: PlayerActor
var sprite: Sprite3D
var facing: int = 0
var travel_distance: float = 0.0
var _previous_position: Vector3

func _ready() -> void:
	process_physics_priority = 10
	_previous_position = actor.global_position
	_build_sprite()
	_build_shadow()
	_sync_position()

func _physics_process(_delta: float) -> void:
	var displacement: Vector3 = actor.global_position - _previous_position
	_previous_position = actor.global_position
	_sync_position()
	if Vector2(actor.velocity.x, actor.velocity.z).length_squared() < 0.000001:
		update_motion(Vector3.ZERO)
	else:
		update_motion(displacement)

func update_motion(displacement: Vector3) -> void:
	var movement: Vector2 = Vector2(displacement.x, displacement.z)
	if movement.length_squared() < 0.000001:
		travel_distance = 0.0
		sprite.frame_coords = Vector2i(0, facing)
		return
	var next_facing: int = _facing_for(movement)
	if next_facing != facing:
		travel_distance = 0.0
	facing = next_facing
	travel_distance = fmod(travel_distance + movement.length(), FRAME_DISTANCE * WALK_POSES.size())
	var phase: int = int(travel_distance / FRAME_DISTANCE)
	var poses: Array[int] = BACK_WALK_POSES if facing == 0 else WALK_POSES
	sprite.frame_coords = Vector2i(poses[phase], facing)

func _facing_for(movement: Vector2) -> int:
	if absf(movement.x) > absf(movement.y):
		return 3 if movement.x > 0.0 else 2
	return 1 if movement.y > 0.0 else 0

func _sync_position() -> void:
	global_position = Vector3(actor.global_position.x, 0.025, actor.global_position.z + VISUAL_DEPTH)

func _build_sprite() -> void:
	sprite = Sprite3D.new()
	sprite.name = "Sprite"
	sprite.texture = ATLAS
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.pixel_size = PIXEL_SIZE
	sprite.position.y = FOOT_BASELINE * PIXEL_SIZE
	sprite.shaded = false
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	add_child(sprite)

func _build_shadow() -> void:
	var shadow: MeshInstance3D = MeshInstance3D.new()
	shadow.name = "ContactShadow"
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(0.82, 0.48)
	shadow.mesh = mesh
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, blend_mix, depth_draw_never, cull_disabled;\nvoid fragment() { ALBEDO = vec3(0.10, 0.075, 0.08); ALPHA = 0.45 * (1.0 - smoothstep(0.08, 0.5, distance(UV, vec2(0.5)))); }"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	shadow.material_override = material
	add_child(shadow)
