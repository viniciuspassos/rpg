extends Node3D

const PlayerScript = preload("res://game/actors/player.gd")
const KeyboardControls = preload("res://game/keyboard_controls.gd")
const IllustratedPresentation = preload("res://game/actors/illustrated_protagonist.gd")
const ArenaPaving: PackedScene = preload("res://game/art/arena_paving.glb")
const ArenaEdgeDetails: PackedScene = preload("res://game/art/arena_edge_details.glb")
const BACKDROP: Texture2D = preload("res://game/art/village_duel_clean.png")
const MAGIC: Texture2D = preload("res://game/art/duel_magic_layer.png")
const MagicPartitionShader: Shader = preload("res://game/art/duel_magic_partition.gdshader")
const PAVING_ALBEDO: Texture2D = preload("res://game/art/arena_paving_albedo.png")
const PAVING_RIM: Texture2D = preload("res://game/art/arena_paving_rim.png")
const OPPONENT: Texture2D = preload("res://game/art/opponent_static.png")
const ARENA_CENTER: Vector2 = Vector2(-0.2, 1.75)
const ARENA_RADII: Vector2 = Vector2(1.9, 1.35)
const MODEL_CENTER_Z: float = 2.05
const MODEL_RADII: Vector2 = Vector2(2.1, 0.75)
const BARRIER_SEGMENTS: int = 48
const MAGIC_SOURCE_RECT: Rect2 = Rect2(610.0, 190.0, 752.4, 423.45)
const MAGIC_ATMOSPHERE_OPACITY: float = 0.62
const MAGIC_FRAGMENTS_OPACITY: float = 0.68
const MAGIC_ENERGY_OPACITY: float = 0.52
# Coordinates from the transparent source image keep the pose registered to the fixed plate.
const OPPONENT_RECT: Rect2 = Rect2(994.0, 261.0, 211.0, 321.0)
const OPPONENT_FOOT_PIXEL: Vector2 = Vector2(1188.0, 580.0)
const OPPONENT_FOOT_HEIGHT: float = 1.0

func _ready() -> void:
	KeyboardControls.install()
	_build_backdrop()
	_build_arena()
	_build_edge_details()
	_build_barrier()
	_build_player()
	_build_camera()
	_build_opponent()

func _build_backdrop() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var settings: Environment = Environment.new()
	settings.background_mode = Environment.BG_CANVAS
	settings.background_canvas_max_layer = -1
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("#ddc2a5")
	settings.ambient_light_energy = 0.75
	environment.environment = settings
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42.0, -35.0, 0.0)
	sun.light_color = Color("#ffd2a6")
	sun.light_energy = 1.25
	add_child(sun)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "Backdrop"
	layer.layer = -1
	add_child(layer)
	var image: TextureRect = TextureRect.new()
	image.name = "Plate"
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.texture = BACKDROP
	layer.add_child(image)
	_add_magic_pass(layer, "MagicAtmosphere", 0, MAGIC_ATMOSPHERE_OPACITY)
	_add_magic_pass(layer, "MagicFragments", 1, MAGIC_FRAGMENTS_OPACITY)
	_add_magic_pass(layer, "MagicEnergy", 2, MAGIC_ENERGY_OPACITY)

func _add_magic_pass(layer: CanvasLayer, node_name: String, pass_index: int, opacity: float) -> void:
	var magic: TextureRect = TextureRect.new()
	magic.name = node_name
	var magic_rect: Rect2 = _source_screen_rect(MAGIC_SOURCE_RECT)
	magic.position = magic_rect.position
	magic.size = magic_rect.size
	magic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	magic.stretch_mode = TextureRect.STRETCH_SCALE
	magic.texture = MAGIC
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = MagicPartitionShader
	material.set_shader_parameter("pass_index", pass_index)
	material.set_shader_parameter("opacity", opacity)
	magic.material = material
	layer.add_child(magic)

func _source_screen_rect(source_rect: Rect2) -> Rect2:
	var size: Vector2 = get_viewport().get_visible_rect().size
	var source_size: Vector2 = BACKDROP.get_size()
	var scale: float = maxf(size.x / source_size.x, size.y / source_size.y)
	var offset: Vector2 = (size - source_size * scale) * 0.5
	return Rect2(source_rect.position * scale + offset, source_rect.size * scale)

func _build_opponent() -> void:
	var camera: Camera3D = get_node("FixedCamera") as Camera3D
	var foot_screen: Vector2 = _opponent_screen_pixel(OPPONENT_FOOT_PIXEL)
	var ray_origin: Vector3 = camera.project_ray_origin(foot_screen)
	var ray_direction: Vector3 = camera.project_ray_normal(foot_screen)
	var foot_position: Vector3 = ray_origin + ray_direction * ((OPPONENT_FOOT_HEIGHT - ray_origin.y) / ray_direction.y)
	var depth: float = -camera.to_local(foot_position).z
	var opponent: Sprite3D = Sprite3D.new()
	opponent.name = "OpponentStatic"
	opponent.texture = OPPONENT
	opponent.region_enabled = true
	opponent.region_rect = OPPONENT_RECT
	opponent.pixel_size = 2.0 * depth * tan(deg_to_rad(camera.fov) * 0.5) / float(OPPONENT.get_height())
	opponent.shaded = false
	opponent.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	opponent.global_transform = Transform3D(camera.global_basis, camera.project_position(_opponent_screen_pixel(OPPONENT_RECT.get_center()), depth))
	add_child(opponent)

func _opponent_screen_pixel(source: Vector2) -> Vector2:
	var size: Vector2 = get_viewport().get_visible_rect().size
	var texture_size: Vector2 = OPPONENT.get_size()
	var scale: float = maxf(size.x / texture_size.x, size.y / texture_size.y)
	return source * scale + (size - texture_size * scale) * 0.5

func _build_arena() -> void:
	var ground: StaticBody3D = StaticBody3D.new()
	ground.name = "ArenaGround"
	add_child(ground)
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(ARENA_RADII.x * 2.0 + 1.0, 0.2, ARENA_RADII.y * 2.0 + 1.0)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(ARENA_CENTER.x, -0.1, ARENA_CENTER.y)
	ground.add_child(collision)
	var paving: Node3D = ArenaPaving.instantiate() as Node3D
	paving.name = "ArenaPaving"
	paving.scale = Vector3(ARENA_RADII.x / MODEL_RADII.x, 1.0, ARENA_RADII.y / MODEL_RADII.y)
	paving.position = Vector3(ARENA_CENTER.x, 0.0, ARENA_CENTER.y - MODEL_CENTER_Z * paving.scale.z)
	ground.add_child(paving)
	var floor_material: ShaderMaterial = _floor_material()
	for child: Node in paving.find_children("*", "MeshInstance3D", true, false):
		var floor_mesh: MeshInstance3D = child as MeshInstance3D
		floor_mesh.material_override = floor_material

func _build_edge_details() -> void:
	var details: Node3D = ArenaEdgeDetails.instantiate() as Node3D
	details.name = "ArenaEdgeDetails"
	add_child(details)

func _build_barrier() -> void:
	var barrier: StaticBody3D = StaticBody3D.new()
	barrier.name = "ArenaBarrier"
	add_child(barrier)
	for segment: int in range(BARRIER_SEGMENTS):
		var first: float = TAU * float(segment) / float(BARRIER_SEGMENTS)
		var second: float = TAU * float(segment + 1) / float(BARRIER_SEGMENTS)
		var start: Vector2 = ARENA_CENTER + Vector2(cos(first) * ARENA_RADII.x, sin(first) * ARENA_RADII.y)
		var end: Vector2 = ARENA_CENTER + Vector2(cos(second) * ARENA_RADII.x, sin(second) * ARENA_RADII.y)
		var edge: Vector2 = end - start
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = Vector3(edge.length() + 0.08, 2.2, 0.14)
		var collision: CollisionShape3D = CollisionShape3D.new()
		collision.shape = shape
		collision.position = Vector3((start.x + end.x) * 0.5, 1.1, (start.y + end.y) * 0.5)
		collision.rotation.y = -edge.angle()
		barrier.add_child(collision)

func _floor_material() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	# The UV floor blends into its own camera-matched rim over the neutralized plate.
	shader.code = """
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D paving : source_color, filter_linear;
uniform sampler2D floor_rim : source_color, filter_linear;
uniform sampler2D magic : source_color, filter_linear, repeat_disable;
uniform vec2 magic_uv_origin;
uniform vec2 magic_uv_size;
uniform float magic_atmosphere_opacity;
uniform float magic_fragments_opacity;
uniform float magic_energy_opacity;
varying vec3 relief_normal;
void vertex() {
	relief_normal = NORMAL;
}
void fragment() {
	vec3 reference = texture(floor_rim, SCREEN_UV).rgb;
	vec3 stone = texture(paving, UV).rgb;
	float rim = length(UV * 2.0 - 1.0);
	float fade = 1.0 - smoothstep(0.55, 1.0, rim);
	vec3 color = mix(reference, stone, fade);
	vec2 effect_uv = (SCREEN_UV - magic_uv_origin) / magic_uv_size;
	if (effect_uv.x >= 0.0 && effect_uv.x <= 1.0 && effect_uv.y >= 0.0 && effect_uv.y <= 1.0) {
		vec4 effect = texture(magic, effect_uv);
		float energy = smoothstep(0.04, 0.16, effect.b - effect.r);
		float debris = (1.0 - energy) * smoothstep(0.55, 0.9, effect.a);
		float dust = 1.0 - energy - debris;
		float gray = dot(effect.rgb, vec3(0.299, 0.587, 0.114));
		vec3 energy_color = mix(effect.rgb, vec3(gray), 0.35);
		color = mix(color, effect.rgb, effect.a * dust * magic_atmosphere_opacity);
		color = mix(color, effect.rgb, effect.a * debris * magic_fragments_opacity);
		color = mix(color, energy_color, effect.a * energy * magic_energy_opacity);
	}
	vec3 sun = normalize(vec3(-0.45, 0.85, 0.25));
	float relief = (dot(normalize(relief_normal), sun) - sun.y) * 0.65;
	ALBEDO = color * 0.08 * fade;
	EMISSION = color * (1.0 - 0.08 * fade) * (1.0 + relief * fade);
	ROUGHNESS = 1.0;
}
"""
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("paving", PAVING_ALBEDO)
	material.set_shader_parameter("floor_rim", PAVING_RIM)
	material.set_shader_parameter("magic", MAGIC)
	var magic_rect: Rect2 = _source_screen_rect(MAGIC_SOURCE_RECT)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	material.set_shader_parameter("magic_uv_origin", magic_rect.position / viewport_size)
	material.set_shader_parameter("magic_uv_size", magic_rect.size / viewport_size)
	material.set_shader_parameter("magic_atmosphere_opacity", MAGIC_ATMOSPHERE_OPACITY)
	material.set_shader_parameter("magic_fragments_opacity", MAGIC_FRAGMENTS_OPACITY)
	material.set_shader_parameter("magic_energy_opacity", MAGIC_ENERGY_OPACITY)
	return material

func _build_player() -> void:
	var actor: PlayerActor = PlayerScript.new() as PlayerActor
	actor.name = "ArenaPlayer"
	actor.position = Vector3(-0.3, 0.1, 2.45)
	actor.arena_center = ARENA_CENTER
	actor.arena_radii = ARENA_RADII
	actor.fixed_camera = true
	actor.walk_speed = 1.15
	add_child(actor)
	actor.protagonist_model.visible = false
	actor.camera.current = false
	var presentation: IllustratedProtagonist = IllustratedPresentation.new()
	presentation.name = "IllustratedProtagonist"
	presentation.actor = actor
	add_child(presentation)

func _build_camera() -> void:
	var camera: Camera3D = Camera3D.new()
	camera.name = "FixedCamera"
	camera.position = Vector3(0.5, 3.35, 5.2)
	camera.fov = 54.0
	add_child(camera)
	camera.look_at(Vector3(0.0, 1.35, 2.3))
	camera.current = true
