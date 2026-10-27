extends Node3D

const PlayerScript = preload("res://game/actors/player.gd")
const KeyboardControls = preload("res://game/keyboard_controls.gd")
const IllustratedPresentation = preload("res://game/actors/illustrated_protagonist.gd")
const BACKDROP: Texture2D = preload("res://game/art/village_backdrop.png")
const ARENA_CENTER: Vector2 = Vector2(0.0, 2.05)
const ARENA_RADII: Vector2 = Vector2(2.1, 0.75)
const WALK_RADII: Vector2 = Vector2(1.45, 0.6)

func _ready() -> void:
	KeyboardControls.install()
	_build_backdrop()
	_build_arena()
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
	layer.layer = -1
	add_child(layer)
	var image: TextureRect = TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.texture = BACKDROP
	layer.add_child(image)

func _build_arena() -> void:
	var ground: StaticBody3D = StaticBody3D.new()
	ground.name = "Small playable ring"
	add_child(ground)
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(ARENA_RADII.x * 2.0 + 1.0, 0.2, ARENA_RADII.y * 2.0 + 1.0)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(ARENA_CENTER.x, -0.1, ARENA_CENTER.y)
	ground.add_child(collision)
	var floor_mesh: MeshInstance3D = MeshInstance3D.new()
	floor_mesh.name = "Reference-matched paving"
	floor_mesh.mesh = _arena_mesh()
	floor_mesh.material_override = _floor_material()
	ground.add_child(floor_mesh)

func _arena_mesh() -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment: int in range(64):
		var first: float = TAU * float(segment) / 64.0
		var second: float = TAU * float(segment + 1) / 64.0
		for vertex: Vector3 in [
			Vector3(ARENA_CENTER.x, 0.01, ARENA_CENTER.y),
			Vector3(ARENA_CENTER.x + cos(first) * ARENA_RADII.x, 0.01, ARENA_CENTER.y + sin(first) * ARENA_RADII.y),
			Vector3(ARENA_CENTER.x + cos(second) * ARENA_RADII.x, 0.01, ARENA_CENTER.y + sin(second) * ARENA_RADII.y)
		]:
			surface.add_vertex(vertex)
	return surface.commit()

func _floor_material() -> ShaderMaterial:
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;\nrender_mode unshaded, cull_disabled;\nuniform sampler2D plate : source_color, filter_linear;\nvoid fragment() { ALBEDO = texture(plate, SCREEN_UV).rgb; }"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("plate", BACKDROP)
	return material

func _build_player() -> void:
	var actor: PlayerActor = PlayerScript.new() as PlayerActor
	actor.position = Vector3(-0.4, 0.1, 2.7)
	actor.arena_center = ARENA_CENTER
	actor.arena_radii = WALK_RADII
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
