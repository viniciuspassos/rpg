extends Node3D

const PlayerScript = preload("res://game/actors/player.gd")
const KeyboardControls = preload("res://game/keyboard_controls.gd")
const IllustratedPresentation = preload("res://game/actors/illustrated_protagonist.gd")
const ArenaPaving: PackedScene = preload("res://game/art/arena_paving.glb")
const BACKDROP: Texture2D = preload("res://game/art/village_duel_empty.png")
const OPPONENT: Texture2D = preload("res://game/art/opponent_static.png")
const ARENA_CENTER: Vector2 = Vector2(-0.2, 1.55)
const ARENA_RADII: Vector2 = Vector2(1.9, 1.15)
const MODEL_CENTER_Z: float = 2.05
const MODEL_RADII: Vector2 = Vector2(2.1, 0.75)
const BARRIER_SEGMENTS: int = 48

func _ready() -> void:
	KeyboardControls.install()
	_build_backdrop()
	_build_opponent()
	_build_arena()
	_build_barrier()
	_build_player()
	_build_camera()

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

func _build_opponent() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "Opponent"
	layer.layer = -1
	add_child(layer)
	var image: TextureRect = TextureRect.new()
	image.name = "StaticPose"
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.texture = OPPONENT
	layer.add_child(image)

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
	var material: ShaderMaterial = _floor_material()
	for child: Node in paving.find_children("*", "MeshInstance3D", true, false):
		var floor_mesh: MeshInstance3D = child as MeshInstance3D
		floor_mesh.material_override = material

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
	shader.code = "shader_type spatial;\nrender_mode unshaded, cull_disabled;\nuniform sampler2D plate : source_color, filter_linear;\nvoid fragment() { ALBEDO = texture(plate, SCREEN_UV).rgb; }"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("plate", BACKDROP)
	return material

func _build_player() -> void:
	var actor: PlayerActor = PlayerScript.new() as PlayerActor
	actor.name = "ArenaPlayer"
	actor.position = Vector3(-0.15, 0.1, 2.58)
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
