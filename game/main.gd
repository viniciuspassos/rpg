extends Node3D

const PlayerScript = preload("res://game/actors/player.gd")
const GuardScript = preload("res://game/actors/guard.gd")
const PowerMarkerScript = preload("res://game/actors/power_marker.gd")
const QuestRules = preload("res://game/village/village_quest_rules.gd")
const QuestDirector = preload("res://game/village/village_quest_director.gd")
const KeyboardControls = preload("res://game/keyboard_controls.gd")

const STONE_GOLD: Color = Color("#d8ae63")
const INK: Color = Color("#20242a")

var player: PlayerActor
var guard: GuardActor
var director: VillageQuestDirector
var hud: CanvasLayer
var objective_label: Label
var health_label: Label
var health_bar: ProgressBar
var ability_label: Label
var prompt_label: Label
var toast_label: Label
var modal: PanelContainer
var modal_title: Label
var modal_body: Label
var modal_options: VBoxContainer
var title_screen: Control
var title_first_button: Button
var setup_feedback: Label
var pause_overlay: Control
var pause_first_button: Button
var trial_target: MeshInstance3D
var map_door: StaticBody3D
var village_gate: StaticBody3D
var friend_cape: MeshInstance3D
var keeper_cloak: MeshInstance3D
var friend_actor: Node3D
var carried_rope: MeshInstance3D
var bell_rope: MeshInstance3D
var interactables: Array[Node3D] = []
var toast_timer: float = 0.0
var talking: bool = false
var game_started: bool = false

func _ready() -> void:
	GameSession.set_language(GameSession.language)
	KeyboardControls.install()
	_build_world()
	_build_player()
	_build_hud()
	_connect_actors()
	director = QuestDirector.new(GameSession.state) as VillageQuestDirector
	if GameSession.state.beat == RunState.Beat.SETUP:
		_show_setup()
	else:
		_resume_existing_run()

func _build_world() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#596d7b")
	sky_material.sky_horizon_color = Color("#edb889")
	sky_material.ground_bottom_color = Color("#342d2c")
	sky_material.ground_horizon_color = Color("#d79a69")
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d8b89a")
	env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	environment.environment = env
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.light_color = Color("#ffd0a0")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	add_child(sun)
	_make_box(Vector3(0, -0.25, 0), Vector3(34, 0.5, 34), Color("#49494a"), true)
	_build_square_details()
	_build_houses()
	_build_npcs()
	_build_interaction_objects()
	_build_power_marker()

func _build_square_details() -> void:
	_make_box(Vector3(-16.5, 1.8, 0), Vector3(0.6, 3.6, 34), Color("#72685f"), true)
	_make_box(Vector3(16.5, 1.8, 0), Vector3(0.6, 3.6, 34), Color("#72685f"), true)
	_make_box(Vector3(0, 1.8, -16.5), Vector3(34, 3.6, 0.6), Color("#72685f"), true)
	_make_box(Vector3(-9.625, 1.8, 16.5), Vector3(12.75, 3.6, 0.6), Color("#72685f"), true)
	_make_box(Vector3(9.625, 1.8, 16.5), Vector3(12.75, 3.6, 0.6), Color("#72685f"), true)
	_make_box(Vector3(0, -0.25, 24), Vector3(6.5, 0.5, 15), Color("#75685b"), true)
	_build_paving()
	_make_well(Vector3(-5.2, 0, 0.7))
	_make_banner(Vector3(0.8, 0, -3.7))
	for tree_position: Vector3 in [Vector3(-10, 0, -7), Vector3(10, 0, 8), Vector3(-11, 0, 10), Vector3(12, 0, -9)]:
		_make_tree(tree_position)
	for stair_index: int in range(5):
		_make_box(Vector3(0, stair_index * 0.2, -11 - stair_index * 0.65), Vector3(10, 0.4, 0.9), Color("#7c716d"), true)

func _build_paving() -> void:
	var palette: Array[Color] = [
		Color("#424b55"), Color("#5d656d"), Color("#756d66"),
		Color("#535b62"), Color("#6d605c"), Color("#847261")
	]
	var variation: RandomNumberGenerator = RandomNumberGenerator.new()
	variation.seed = 71942
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row: int in range(48):
		var z: float = -16.2 + row * 0.69
		var x: float = -16.5 + variation.randf_range(-0.3, 0.3)
		var column: int = 0
		while x < 16.5:
			var width: float = variation.randf_range(0.72, 1.55)
			var depth: float = variation.randf_range(0.60, 0.665)
			var tone: Color = palette[(row * 11 + column * 7 + row * column) % palette.size()]
			var corners: PackedVector3Array = PackedVector3Array([
				Vector3(x, 0.025, z), Vector3(x, 0.025, z + depth),
				Vector3(x + width, 0.025, z + depth), Vector3(x + width, 0.025, z)
			])
			surface.set_color(tone)
			for index: int in [0, 1, 2, 0, 2, 3]:
				surface.add_vertex(corners[index])
			x += width + 0.045
			column += 1
	surface.generate_normals()
	var paving: MeshInstance3D = MeshInstance3D.new()
	paving.name = "Stone paving"
	paving.mesh = surface.commit()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 1.0
	paving.material_override = material
	add_child(paving)

func _build_houses() -> void:
	_make_house(Vector3(-9, 0, 0), Color("#b97656"), Color("#425262"))
	_make_house(Vector3(9, 0, 0), Color("#c28a63"), Color("#58464a"))
	_make_house(Vector3(-8, 0, -9), Color("#b18a68"), Color("#394a59"))
	_make_house(Vector3(8, 0, 9), Color("#bd795d"), Color("#4a5155"))
	_make_box(Vector3(9, 1, -2.7), Vector3(1.4, 2, 0.2), Color("#594032"), true)
	map_door = _last_mesh.get_parent() as StaticBody3D
	_make_box(Vector3(9, 0.75, 0), Vector3(2.4, 0.12, 1.4), Color("#684d39"), false)
	_make_box(Vector3(9, 0.38, -0.55), Vector3(0.12, 0.75, 0.12), Color("#594331"), false)
	_make_box(Vector3(9, 0.38, 0.55), Vector3(0.12, 0.75, 0.12), Color("#594331"), false)
	_make_box(Vector3(9, 0.83, 0), Vector3(0.72, 0.02, 0.52), Color("#d0ba8f"), false)
	_make_box(Vector3(0, 0.9, 15.5), Vector3(6.5, 1.8, 0.45), Color("#694b38"), true)
	village_gate = _last_mesh.get_parent() as StaticBody3D

var _last_mesh: MeshInstance3D

func _make_house(center: Vector3, wall_color: Color, roof_color: Color) -> void:
	_make_box(center + Vector3(0, 1.3, 2.65), Vector3(6.5, 2.6, 0.2), wall_color, true)
	_make_box(center + Vector3(-3.15, 1.3, 0), Vector3(0.2, 2.6, 5.5), wall_color, true)
	_make_box(center + Vector3(3.15, 1.3, 0), Vector3(0.2, 2.6, 5.5), wall_color, true)
	_make_box(center + Vector3(-2.25, 1.3, -2.65), Vector3(2.0, 2.6, 0.2), wall_color, true)
	_make_box(center + Vector3(2.25, 1.3, -2.65), Vector3(2.0, 2.6, 0.2), wall_color, true)
	_make_box(center + Vector3(0, 2.35, -2.65), Vector3(1.5, 0.5, 0.2), wall_color, true)
	var roof: MeshInstance3D = _make_box(center + Vector3(0, 3.05, 0), Vector3(7.2, 0.6, 6.1), roof_color, true)
	roof.rotation.z = deg_to_rad(-4)
	_make_box(center + Vector3(0, 0.9, -2.8), Vector3(1.2, 1.8, 0.12), Color("#49392f"), false)
	_make_box(center + Vector3(-2.1, 1.5, -2.82), Vector3(0.75, 0.9, 0.08), Color("#373f44"), false)
	_make_box(center + Vector3(2.1, 1.5, -2.82), Vector3(0.75, 0.9, 0.08), Color("#373f44"), false)

func _make_well(at: Vector3) -> void:
	var well: StaticBody3D = StaticBody3D.new()
	well.name = "Covered well"
	well.position = at
	well.rotation.y = deg_to_rad(-42.0)
	well.scale = Vector3.ONE * 0.72
	add_child(well)
	_make_box_child(well, Vector3(0, 0.38, 0), Vector3(2.55, 0.76, 2.0), Color("#41484f"))
	var base_collision: CollisionShape3D = CollisionShape3D.new()
	var base_shape: BoxShape3D = BoxShape3D.new()
	base_shape.size = Vector3(2.55, 0.76, 2.0)
	base_collision.position.y = 0.38
	base_collision.shape = base_shape
	well.add_child(base_collision)
	_make_box_child(well, Vector3(0, 0.79, 0), Vector3(1.95, 0.04, 1.4), Color("#252d32"))
	for side: int in [-1, 1]:
		_make_box_child(well, Vector3(side * 1.05, 0.82, 0), Vector3(0.38, 0.23, 2.05), Color("#555a5d"))
		_make_box_child(well, Vector3(0, 0.82, side * 0.83), Vector3(2.55, 0.23, 0.38), Color("#4e5559"))
		for end: int in [-1, 1]:
			var post_position: Vector3 = Vector3(side * 1.37, 2.05, end * 1.12)
			_make_box_child(well, post_position, Vector3(0.2, 2.8, 0.2), Color("#554035"))
			var post_collision: CollisionShape3D = CollisionShape3D.new()
			var post_shape: BoxShape3D = BoxShape3D.new()
			post_shape.size = Vector3(0.2, 2.8, 0.2)
			post_collision.position = post_position
			post_collision.shape = post_shape
			well.add_child(post_collision)
			var brace: MeshInstance3D = _make_box_child(well, Vector3(side * 1.08, 3.05, end * 1.12), Vector3(0.16, 0.9, 0.16), Color("#614637"))
			brace.rotation.z = deg_to_rad(side * -39.0)
		var slope: MeshInstance3D = _make_box_child(well, Vector3(side * 0.97, 4.1, 0), Vector3(2.2, 0.14, 4.0), Color("#60453d"))
		slope.rotation.z = deg_to_rad(side * -33.0)
		var roof_collision: CollisionShape3D = CollisionShape3D.new()
		var roof_shape: BoxShape3D = BoxShape3D.new()
		roof_shape.size = Vector3(2.2, 0.14, 4.0)
		roof_collision.position = slope.position
		roof_collision.rotation.z = slope.rotation.z
		roof_collision.shape = roof_shape
		well.add_child(roof_collision)
		var fascia: MeshInstance3D = _make_box_child(well, Vector3(side * 0.98, 3.98, 0), Vector3(2.23, 0.12, 4.12), Color("#46372f"))
		fascia.rotation.z = deg_to_rad(side * -33.0)
	_make_box_child(well, Vector3(0, 4.72, 0), Vector3(0.19, 0.18, 4.2), Color("#604236"))
	_make_box_child(well, Vector3(0, 3.1, 0), Vector3(2.9, 0.17, 0.18), Color("#513a30"))
	_make_cylinder_child(well, Vector3(0, 2.2, 0), Vector2(0.035, 1.7), Color("#9d7951"))
	_make_cylinder_child(well, Vector3(0, 1.25, 0), Vector2(0.28, 0.42), Color("#453a32"))

func _make_banner(at: Vector3) -> void:
	_make_box(at + Vector3(0, 2.0, 0), Vector3(0.16, 4.0, 0.16), Color("#544434"), true)
	_make_box(at + Vector3(0, 3.85, 0), Vector3(2.5, 0.16, 0.16), Color("#544434"), true)
	_make_box(at + Vector3(0.55, 2.95, 0), Vector3(1.35, 1.75, 0.11), Color("#984e37"), false)

func _make_tree(at: Vector3) -> void:
	_make_cylinder(at + Vector3(0, 1.4, 0), 0.32, 2.8, Color("#574536"))
	_make_sphere(at + Vector3(0, 3.1, 0), Vector3(2.4, 2.1, 2.4), Color("#68714a"), 6)
	_make_sphere(at + Vector3(0.8, 3.4, 0.2), Vector3(1.65, 1.6, 1.65), Color("#77804e"), 5)

func _build_npcs() -> void:
	_make_npc("keeper", "keeper", Vector3(-2.3, 0, 5.2), Color("#733a48"))
	_make_npc("friend", "acquaintance", Vector3(-3.1, 0, 6.5), Color("#61724d"))
	_make_npc("leader", "leader", Vector3(4.0, 0, 2.4), Color("#8a443a"))
	_make_npc("visitor", "visitor", Vector3(6.2, 0, 3.7), Color("#3b5262"))

func _build_interaction_objects() -> void:
	_make_interactable("bell", Vector3(0, 0, 5.4), Color("#c19453"))
	_make_interactable("rope_bundle", Vector3(-5.5, 0, 3.3), Color("#c9aa76"))
	_make_interactable("letter", Vector3(6.6, 0, -5.4), Color("#d1ba8a"))

func _build_power_marker() -> void:
	trial_target = _make_sphere(Vector3(0, 0.75, -9.4), Vector3(1.2, 1.2, 1.2), Color("#bce0e9"), 5)
	var glow: StandardMaterial3D = trial_target.material_override as StandardMaterial3D
	glow.emission_enabled = true
	glow.emission = Color("#91d8ed")
	glow.emission_energy_multiplier = 2.2
	trial_target.add_to_group("power_target")
	trial_target.visible = false
	_make_box(Vector3(0, 0.35, -9.4), Vector3(2.1, 0.7, 2.1), Color("#645f5a"), true)
	trial_target.set_script(PowerMarkerScript)
	_make_cylinder(Vector3(-1.4, 0.35, -9.4), 0.35, 0.7, Color("#777b78"))
	_make_cylinder(Vector3(1.4, 0.35, -9.4), 0.35, 0.7, Color("#777b78"))

func _build_player() -> void:
	player = PlayerScript.new() as PlayerActor
	player.position = Vector3(0, 0.1, 7.6)
	add_child(player)
	var coil: TorusMesh = TorusMesh.new()
	coil.inner_radius = 0.16
	coil.outer_radius = 0.24
	coil.rings = 8
	coil.ring_segments = 6
	carried_rope = MeshInstance3D.new()
	carried_rope.mesh = coil
	carried_rope.position = Vector3(0.35, 0.72, -0.38)
	carried_rope.rotation.x = deg_to_rad(72)
	carried_rope.material_override = _material(Color("#c9aa76"))
	carried_rope.visible = false
	player.add_child(carried_rope)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var root: Control = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(root)
	var top_card: PanelContainer = _make_panel(root, Vector2(34, 30), Vector2(330, 75))
	var top_stack: VBoxContainer = VBoxContainer.new()
	top_card.add_child(top_stack)
	objective_label = _label("", 19, Color("#fff4df"))
	top_stack.add_child(objective_label)
	var bottom_panel: PanelContainer = _make_panel(root, Vector2(34, 705), Vector2(360, 75))
	var bottom_stack: VBoxContainer = VBoxContainer.new()
	bottom_panel.add_child(bottom_stack)
	health_label = _label("HEALTH", 18, Color("#fff4df"))
	bottom_stack.add_child(health_label)
	health_bar = ProgressBar.new()
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(320, 12)
	var track: StyleBoxFlat = StyleBoxFlat.new()
	track.bg_color = Color("#343031")
	track.set_corner_radius_all(4)
	health_bar.add_theme_stylebox_override("background", track)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("#b84a40")
	fill.set_corner_radius_all(4)
	health_bar.add_theme_stylebox_override("fill", fill)
	bottom_stack.add_child(health_bar)
	ability_label = _label("POWER_LOCKED", 12, Color("#bbdce5"))
	ability_label.visible = false
	bottom_stack.add_child(ability_label)
	var crosshair: Label = _label("◇", 26, Color("#f2d68e"))
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	root.add_child(crosshair)
	prompt_label = _label("", 15, Color("#fff4df"))
	prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_label.position = Vector2(-220, -105)
	prompt_label.size = Vector2(440, 36)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(prompt_label)
	toast_label = _label("", 16, Color("#ffe0a1"))
	toast_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_label.position = Vector2(-360, 155)
	toast_label.size = Vector2(720, 42)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(toast_label)
	_build_modal(root)
	_build_pause(root)
	_build_title(root)
	_update_hud()

func _build_modal(root: Control) -> void:
	modal = _make_panel(root, Vector2.ZERO, Vector2(780, 420))
	_center_panel(modal, Vector2(780, 420))
	modal.visible = false
	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	modal.add_child(stack)
	modal_title = _label("", 25, STONE_GOLD)
	stack.add_child(modal_title)
	modal_body = _label("", 17, Color("#eee5d6"))
	modal_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	modal_body.custom_minimum_size.y = 112
	stack.add_child(modal_body)
	modal_options = VBoxContainer.new()
	modal_options.add_theme_constant_override("separation", 8)
	stack.add_child(modal_options)

func _build_pause(root: Control) -> void:
	pause_overlay = Control.new()
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	root.add_child(pause_overlay)
	var panel: PanelContainer = _make_panel(pause_overlay, Vector2.ZERO, Vector2(360, 240))
	_center_panel(panel, Vector2(360, 240))
	var stack: VBoxContainer = VBoxContainer.new()
	panel.add_child(stack)
	stack.add_child(_label("PAUSE", 27, STONE_GOLD))
	pause_first_button = _add_button(stack, "RESUME", Callable(self, "_toggle_pause"))
	_add_button(stack, "RESTART", Callable(self, "_restart_run"))
	_add_button(stack, "BACK_TO_TITLE", Callable(self, "_return_to_title"))

func _build_title(root: Control) -> void:
	title_screen = Control.new()
	title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(title_screen)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.08, 0.09, 0.1, 0.58)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_screen.add_child(shade)
	var panel: PanelContainer = _make_panel(title_screen, Vector2(0, 0), Vector2(560, 690))
	_center_panel(panel, Vector2(560, 690))
	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 7)
	panel.add_child(stack)
	stack.add_child(_label("GAME_TITLE", 36, STONE_GOLD))
	stack.add_child(_label("SUBTITLE", 19, Color("#ece1d1")))
	stack.add_child(_label("CHOOSE_HERO", 14, Color("#aaa194")))
	title_first_button = _add_button(stack, "HERO_FEMALE", Callable(self, "_select_female"))
	_add_button(stack, "HERO_MALE", Callable(self, "_select_male"))
	stack.add_child(_label("CHOOSE_ORIGIN", 14, Color("#aaa194")))
	_add_button(stack, "ORIGIN_FOUNDLING", Callable(self, "_select_foundling"))
	_add_button(stack, "ORIGIN_HAWKWING", Callable(self, "_select_hawkwing"))
	stack.add_child(_label("CHOOSE_MOTIVATION", 14, Color("#aaa194")))
	_add_button(stack, "MOTIVATION_LEAVE", Callable(self, "_select_leave"))
	_add_button(stack, "MOTIVATION_BELONG", Callable(self, "_select_belong"))
	setup_feedback = _label("", 12, Color("#d8c7a9"))
	stack.add_child(setup_feedback)
	_add_button(stack, "LANGUAGE", Callable(self, "_toggle_language"))
	_add_button(stack, "START", Callable(self, "_start_run"))
	stack.add_child(_label("TITLE_PROMPT", 12, Color("#c9c0b3")))
	_update_setup_summary()
	title_screen.visible = false

func _process(delta: float) -> void:
	if not game_started or talking or pause_overlay.visible:
		return
	if GameSession.state.task_complete and not GameSession.state.consequence_shown:
		_move_companion(delta)
	toast_timer = maxf(toast_timer - delta, 0.0)
	if toast_timer == 0.0:
		toast_label.text = ""
	var target: Node3D = _nearest_interactable()
	prompt_label.text = _interaction_prompt(target)
	if Input.is_action_just_pressed("interact") and target != null:
		_interact(str(target.get_meta("target_id")))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and game_started:
		if talking:
			_close_dialogue()
		elif not title_screen.visible:
			_toggle_pause()

func _connect_actors() -> void:
	player.health_changed.connect(_on_health_changed)
	player.attacked.connect(_on_attacked)
	player.power_used.connect(_on_power_used)
	player.defeated.connect(_on_player_defeated)

func _show_setup() -> void:
	title_screen.visible = true
	game_started = false
	player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_first_button.grab_focus()

func _select_female() -> void:
	GameSession.state.protagonist = "female"
	player.set_protagonist_presentation("female")
	_update_setup_summary()

func _select_male() -> void:
	GameSession.state.protagonist = "male"
	player.set_protagonist_presentation("male")
	_update_setup_summary()

func _select_foundling() -> void:
	GameSession.state.origin = "foundling"
	_update_setup_summary()

func _select_hawkwing() -> void:
	GameSession.state.origin = "hawkwing"
	_update_setup_summary()

func _select_leave() -> void:
	GameSession.state.motivation = "leave"
	_update_setup_summary()

func _select_belong() -> void:
	GameSession.state.motivation = "belong"
	_update_setup_summary()

func _update_setup_summary() -> void:
	if setup_feedback == null:
		return
	var state: RunState = GameSession.state
	var protagonist_key: String = "HERO_FEMALE" if state.protagonist == "female" else "HERO_MALE"
	var origin_key: String = "ORIGIN_HAWKWING" if state.origin == "hawkwing" else "ORIGIN_FOUNDLING"
	var motivation_key: String = "MOTIVATION_BELONG" if state.motivation == "belong" else "MOTIVATION_LEAVE"
	setup_feedback.text = _tr("SETUP_SUMMARY") % [_tr(protagonist_key), _tr(origin_key), _tr(motivation_key)]

func _toggle_language() -> void:
	GameSession.set_language("pt_BR" if GameSession.language == "en" else "en")
	get_tree().reload_current_scene()

func _start_run() -> void:
	var run: RunState = GameSession.state
	GameSession.begin_fresh_run(run.protagonist, run.origin, run.motivation)
	director = QuestDirector.new(GameSession.state) as VillageQuestDirector
	_reset_world_for_fresh_run()
	player.reset_for_fresh_run()
	player.position = Vector3(0, 0.1, 7.6)
	player.set_protagonist_presentation(run.protagonist)
	player.set_physics_process(true)
	title_screen.visible = false
	game_started = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_objective(_objective_key())
	_show_toast(_tr("ORIGIN_REACTION_HAWKWING") if run.origin == "hawkwing" else _tr("ORIGIN_REACTION_FOUNDLING"))

func _reset_world_for_fresh_run() -> void:
	_set_blocker_closed(map_door)
	_set_blocker_closed(village_gate)
	keeper_cloak.material_override = _material(Color("#733a48"))
	friend_cape.material_override = _material(Color("#61724d"))
	friend_actor.position = Vector3(-3.1, 0, 6.5)
	var visitor: Node3D = _find_target("visitor")
	if visitor != null:
		visitor.visible = true
	var rope_bundle: Node3D = _find_target("rope_bundle")
	if rope_bundle != null:
		rope_bundle.visible = true
	carried_rope.visible = false
	if is_instance_valid(bell_rope):
		bell_rope.queue_free()
		bell_rope = null
	trial_target.visible = false
	if is_instance_valid(guard):
		guard.queue_free()
		guard = null

func _resume_existing_run() -> void:
	game_started = true
	title_screen.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_apply_saved_scene_state()
	_update_objective(_objective_key())

func _apply_saved_scene_state() -> void:
	var run: RunState = GameSession.state
	if run.beat >= RunState.Beat.SEIZURE:
		_spawn_guard()
		if run.enemy_defeated:
			guard.queue_free()
	if run.power_awakened:
		player.power_unlocked = true
		trial_target.visible = true
	if run.rope_picked:
		carried_rope.visible = not run.task_complete
		var rope_bundle: Node3D = _find_target("rope_bundle")
		if rope_bundle != null:
			rope_bundle.visible = false
	if run.task_complete:
		_tie_rope_to_bell()
	if run.consequence_shown:
		_apply_consequence_visuals()

func _objective_key() -> String:
	var run: RunState = GameSession.state
	if run.beat == RunState.Beat.SETUP:
		return ""
	if run.beat == RunState.Beat.PERSONAL_TASK:
		if not run.keeper_task_talked:
			return "TALK_KEEPER"
		if not run.friend_task_talked:
			return "TALK_ACQUAINTANCE"
		return "TASK_DELIVER" if run.rope_picked else "TASK_PICKUP"
	if run.beat == RunState.Beat.RECORD_REQUEST:
		return "REQUEST_OBJECTIVE"
	if run.beat == RunState.Beat.SEIZURE:
		return "OBJECTIVE_COMBAT"
	if run.beat == RunState.Beat.AWAKENING:
		return "AWAKENING_OBJECTIVE"
	if run.beat == RunState.Beat.POWER_TRIAL:
		return "POWER_OBJECTIVE"
	if run.beat == RunState.Beat.DECISION:
		return "DECISION_OBJECTIVE"
	return "ENDING_TITLE"

func _interact(target_id: String) -> void:
	var run: RunState = GameSession.state
	if target_id == "keeper":
		_interact_keeper()
	elif target_id == "friend":
		_interact_friend()
	elif target_id == "bell":
		_deliver_rope()
	elif target_id == "rope_bundle":
		_pick_up_rope()
	elif target_id == "leader":
		if run.beat == RunState.Beat.RECORD_REQUEST and director.hear_leader_response():
			_show_dialogue("LEADER", "LEADER_RESPONSE_BODY", [{"key": "CONTINUE", "action": Callable(self, "_close_dialogue")}])
			_update_objective(_objective_key())
		else:
			_show_dialogue("LEADER", "LEADER", [{"key": "CLOSE", "action": Callable(self, "_close_dialogue")}])
	elif target_id == "visitor":
		_interact_visitor()
	elif target_id == "letter":
		_read_visitor_order()
	if run.beat == RunState.Beat.COMPLETE:
		_show_ending()

func _interact_keeper() -> void:
	var run: RunState = GameSession.state
	if run.beat == RunState.Beat.PERSONAL_TASK:
		director.mark_keeper_task_talked()
		var origin_key: String = "ORIGIN_REACTION_HAWKWING" if run.origin == "hawkwing" else "ORIGIN_REACTION_FOUNDLING"
		var hero_key: String = "PROTAGONIST_REACTION_FEMALE" if run.protagonist == "female" else "PROTAGONIST_REACTION_MALE"
		var task_text: String = _tr(origin_key) + "\n\n" + _tr(hero_key)
		_show_dialogue("KEEPER", origin_key, [{"key": "TALK_KEEPER", "action": Callable(self, "_close_dialogue")}], task_text)
		_update_objective(_objective_key())
	elif run.beat == RunState.Beat.RECORD_REQUEST and director.hear_keeper_response():
		_show_dialogue("KEEPER", "KEEPER_RESPONSE_BODY", [{"key": "CONTINUE", "action": Callable(self, "_close_dialogue")}])
		_update_objective(_objective_key())
	elif run.beat == RunState.Beat.DECISION:
		_open_custody_choice()
	else:
		_show_dialogue("KEEPER", "KEEPER", [{"key": "CLOSE", "action": Callable(self, "_close_dialogue")}])

func _interact_friend() -> void:
	var run: RunState = GameSession.state
	if run.beat == RunState.Beat.PERSONAL_TASK:
		director.mark_friend_task_talked()
		var key: String = "MOTIVATION_REACTION_" + run.motivation.to_upper()
		_show_dialogue("ACQUAINTANCE", key, [{"key": "TALK_ACQUAINTANCE", "action": Callable(self, "_close_dialogue")}])
		_update_objective(_objective_key())
	elif run.consequence_shown:
		_show_dialogue("ACQUAINTANCE", "ENDING_REASON", [{"key": "CLOSE", "action": Callable(self, "_close_dialogue")}])
	else:
		_show_dialogue("ACQUAINTANCE", "ACQUAINTANCE", [{"key": "CLOSE", "action": Callable(self, "_close_dialogue")}])

func _deliver_rope() -> void:
	var run: RunState = GameSession.state
	if not director.deliver_rope():
		return
	carried_rope.visible = false
	_tie_rope_to_bell()
	var motivation_key: String = "MOTIVATION_REACTION_" + run.motivation.to_upper()
	_show_dialogue("ACQUAINTANCE", motivation_key, [{"key": "REQUEST_OBJECTIVE", "action": Callable(self, "_close_dialogue")}])
	_update_objective("REQUEST_OBJECTIVE")

func _pick_up_rope() -> void:
	var run: RunState = GameSession.state
	if not director.pick_up_rope():
		return
	carried_rope.visible = true
	var bundle: Node3D = _find_target("rope_bundle")
	if bundle != null:
		bundle.visible = false
	_update_objective("TASK_DELIVER")
	_show_toast(_tr("ROPE_PICKED"))

func _tie_rope_to_bell() -> void:
	if is_instance_valid(bell_rope):
		return
	var bell: Node3D = _find_target("bell")
	var loop: TorusMesh = TorusMesh.new()
	loop.inner_radius = 0.18
	loop.outer_radius = 0.26
	loop.rings = 8
	loop.ring_segments = 6
	bell_rope = MeshInstance3D.new()
	bell_rope.mesh = loop
	bell_rope.position = Vector3(0, 0.65, 0)
	bell_rope.rotation.x = PI / 2.0
	bell_rope.material_override = _material(Color("#c9aa76"))
	bell.add_child(bell_rope)

func _interact_visitor() -> void:
	var run: RunState = GameSession.state
	if run.beat == RunState.Beat.RECORD_REQUEST:
		if director.hear_visitor_request():
			var motivation_key: String = "MOTIVATION_REACTION_" + run.motivation.to_upper()
			var conflict: String = _tr("RECORD_REQUEST_BODY") + "\n\n" + _tr("ORDER_BODY") + "\n\n" + _tr(motivation_key)
			_show_dialogue("RECORD_REQUEST_TITLE", "RECORD_REQUEST_BODY", [{"key": "CONTINUE", "action": Callable(self, "_start_request")}], conflict)
			_update_objective(_objective_key())
		elif run.visitor_request_heard:
			_start_request()
	elif run.beat == RunState.Beat.DECISION:
		_open_custody_choice()
	else:
		_show_dialogue("VISITOR", "RECORD_REQUEST_BODY", [{"key": "CLOSE", "action": Callable(self, "_close_dialogue")}])

func _read_visitor_order() -> void:
	if not director.read_order():
		return
	_show_dialogue("ORDER_TITLE", "ORDER_BODY", [{"key": "CONTINUE", "action": Callable(self, "_close_dialogue")}])
	_update_objective(_objective_key())

func _start_request() -> void:
	var run: RunState = GameSession.state
	if not director.start_seizure():
		return
	_close_dialogue()
	_spawn_guard()
	_update_objective("OBJECTIVE_COMBAT")
	_show_dialogue("SEIZURE_TITLE", "SEIZURE_BODY", [{"key": "COMBAT_HINT", "action": Callable(self, "_close_dialogue")}])

func _spawn_guard() -> void:
	if is_instance_valid(guard):
		return
	guard = GuardScript.new() as GuardActor
	guard.position = Vector3(0, 0, -4.8)
	add_child(guard)
	guard.defeated.connect(_on_guard_defeated)

func _on_guard_defeated() -> void:
	var run: RunState = GameSession.state
	if not director.trigger_awakening():
		return
	player.power_unlocked = true
	trial_target.visible = true
	_play_awakening_effect()
	_update_hud()
	_update_objective("AWAKENING_OBJECTIVE")
	var reaction_key: String = "PROTAGONIST_REACTION_FEMALE" if run.protagonist == "female" else "PROTAGONIST_REACTION_MALE"
	var awakening_text: String = _tr("AWAKENING_BODY") + "\n\n" + _tr(reaction_key)
	_show_dialogue("AWAKENING_TITLE", "AWAKENING_BODY", [{"key": "CONTINUE", "action": Callable(self, "_continue_after_awakening")}], awakening_text)

func _continue_after_awakening() -> void:
	if not director.begin_power_trial():
		return
	_close_dialogue()
	_update_objective("POWER_OBJECTIVE")
	_show_toast(_tr("POWER_HINT"))

func _play_awakening_effect() -> void:
	var origin: Vector3 = keeper_cloak.global_position + Vector3(0, 0.9, 0)
	var burst: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radial_segments = 10
	sphere.rings = 6
	burst.mesh = sphere
	burst.position = origin
	var material: StandardMaterial3D = _material(Color("#c7f2fa"))
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color("#9be8f5")
	material.emission_energy_multiplier = 4.0
	burst.material_override = material
	add_child(burst)
	var light: OmniLight3D = OmniLight3D.new()
	light.position = origin
	light.light_color = Color("#9be8f5")
	light.light_energy = 4.0
	light.omni_range = 10.0
	add_child(light)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(burst, "scale", Vector3.ONE * 5.0, 0.7)
	tween.tween_property(burst, "transparency", 1.0, 0.7)
	tween.tween_property(light, "light_energy", 0.0, 0.7)
	tween.chain().tween_callback(burst.queue_free)
	tween.tween_callback(light.queue_free)

func _on_power_used() -> void:
	var run: RunState = GameSession.state
	_update_hud()
	if run.beat != RunState.Beat.POWER_TRIAL or run.power_tried:
		return
	var distance: float = player.global_position.distance_to(trial_target.global_position)
	var facing: float = -player.global_basis.z.dot((trial_target.global_position - player.global_position).normalized())
	if distance <= 7.0 and facing > 0.05:
		if not director.complete_power_trial():
			return
		trial_target.visible = false
		_update_objective("DECISION_OBJECTIVE")
		_show_dialogue("POWER_LABEL", "TRIAL_COMPLETE", [{"key": "DECISION_TITLE", "action": Callable(self, "_close_dialogue")}])
	else:
		_show_toast(_tr("POWER_HINT"))

func _open_custody_choice() -> void:
	_show_dialogue("DECISION_TITLE", "DECISION_STAKES", [
		{"key": "CUSTODY_KEEPER", "action": Callable(self, "_choose_custody").bind("keeper")},
		{"key": "CUSTODY_VISITOR", "action": Callable(self, "_choose_custody").bind("visitor")}
	])

func _choose_custody(choice: String) -> void:
	if not director.choose_custody(choice):
		return
	_show_dialogue("DECISION_TITLE", "DECISION_STAKES", [
		{"key": "TESTIMONY_HONEST", "action": Callable(self, "_choose_testimony").bind("honest")},
		{"key": "TESTIMONY_SILENT", "action": Callable(self, "_choose_testimony").bind("silent")}
	])

func _choose_testimony(choice: String) -> void:
	var run: RunState = GameSession.state
	var result: Dictionary = director.choose_testimony(choice)
	if result.is_empty():
		return
	_apply_consequence_visuals()
	var response_key: String = str(result["response"])
	_show_dialogue("ACQUAINTANCE", response_key, [{"key": "ENDING_TITLE", "action": Callable(self, "_finish_consequence")}])

func _finish_consequence() -> void:
	director.complete_episode()
	_close_dialogue()
	_show_ending()

func _apply_consequence_visuals() -> void:
	var run: RunState = GameSession.state
	friend_cape.material_override = _material(Color("#a5c28a") if run.testimony == "honest" else Color("#564b46"))
	if run.custody == "keeper":
		_set_blocker_open(map_door)
		keeper_cloak.material_override = _material(Color("#d4ae72"))
	else:
		_set_blocker_open(village_gate)
		var visitor: Node3D = _find_target("visitor")
		if visitor != null:
			visitor.visible = false

func _set_blocker_open(blocker: StaticBody3D) -> void:
	blocker.visible = false
	for child: Node in blocker.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", true)

func _set_blocker_closed(blocker: StaticBody3D) -> void:
	blocker.visible = true
	for child: Node in blocker.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).set_deferred("disabled", false)

func _show_ending() -> void:
	var run: RunState = GameSession.state
	if run.beat != RunState.Beat.COMPLETE:
		return
	var result: Dictionary = QuestRules.outcome(run.custody, run.testimony)
	var body: String = _tr(str(result["response"])) + "\n\n" + _tr(str(result["access"])) + "\n" + _tr(str(result["relationship"])) + "\n\n" + _tr("ENDING_REASON")
	_show_dialogue("ENDING_TITLE", body, [
		{"key": "ENDING_CONTINUE", "action": Callable(self, "_restart_run")},
		{"key": "BACK_TO_TITLE", "action": Callable(self, "_return_to_title")}
	])

func _restart_run() -> void:
	GameSession.state.reset()
	GameSession.set_language(GameSession.language)
	get_tree().reload_current_scene()

func _return_to_title() -> void:
	GameSession.state.reset()
	_reset_world_for_fresh_run()
	player.reset_for_fresh_run()
	player.position = Vector3(0, 0.1, 7.6)
	player.camera_pivot.global_position = player.global_position + Vector3(0, 1.35, 0)
	player.set_protagonist_presentation(GameSession.state.protagonist)
	_close_dialogue()
	pause_overlay.visible = false
	title_screen.visible = true
	game_started = false
	player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_first_button.grab_focus()

func _toggle_pause() -> void:
	if not game_started:
		return
	pause_overlay.visible = not pause_overlay.visible
	player.set_physics_process(not pause_overlay.visible)
	if is_instance_valid(guard):
		guard.set_physics_process(not pause_overlay.visible)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if pause_overlay.visible:
		pause_first_button.grab_focus()

func _on_player_defeated() -> void:
	_show_dialogue("DEFEAT_TITLE", "DEFEAT_BODY", [{"key": "RETRY", "action": Callable(self, "_retry_encounter")}])

func _retry_encounter() -> void:
	director.retry_encounter()
	get_tree().reload_current_scene()

func _on_health_changed(current: int, maximum: int) -> void:
	health_label.text = "%s  %d / %d" % [_tr("HEALTH"), current, maximum]
	health_bar.value = current

func _on_attacked() -> void:
	_show_toast(_tr("COMBAT_HINT"))

func _update_hud() -> void:
	health_label.text = "%s  %d / %d" % [_tr("HEALTH"), player.health if player != null else 100, player.max_health if player != null else 100]
	health_bar.value = player.health if player != null else 100
	ability_label.text = "%s  %s" % [_tr("POWER"), str(player.power_uses) if player != null and player.power_unlocked else _tr("POWER_LOCKED")]
	_update_objective(_objective_key())

func _update_objective(key: String) -> void:
	if objective_label != null:
		objective_label.text = _tr(key)

func _show_dialogue(title_key: String, body_key: String, choices: Array[Dictionary], body_override: String = "") -> void:
	talking = true
	player.set_physics_process(false)
	if is_instance_valid(guard):
		guard.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	modal.visible = true
	modal_title.text = _tr(title_key)
	modal_body.text = body_override if not body_override.is_empty() else _tr(body_key)
	_clear_options()
	var first_button: Button
	for choice: Dictionary in choices:
		var button: Button = _add_button(modal_options, str(choice["key"]), choice["action"] as Callable)
		if first_button == null:
			first_button = button
	if first_button != null:
		first_button.grab_focus()

func _clear_options() -> void:
	for child: Node in modal_options.get_children():
		child.queue_free()

func _close_dialogue() -> void:
	modal.visible = false
	talking = false
	if game_started and not pause_overlay.visible:
		player.set_physics_process(true)
		if is_instance_valid(guard) and GameSession.state.beat == RunState.Beat.SEIZURE:
			guard.set_physics_process(true)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _make_panel(parent: Control, at: Vector2, size: Vector2) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.position = at
	panel.custom_minimum_size = size
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.085, 0.09, 0.1, 0.91)
	style.border_color = Color("#7f6848")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _center_panel(panel: PanelContainer, size: Vector2) -> void:
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -size.x / 2.0
	panel.offset_top = -size.y / 2.0
	panel.offset_right = size.x / 2.0
	panel.offset_bottom = size.y / 2.0

func _label(key: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = _tr(key)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _add_button(parent: Node, key: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = _tr(key)
	button.custom_minimum_size.y = 34
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", Color("#f0e6d6"))
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.22, 0.21, 0.2, 0.92)
	normal.border_color = Color("#786343")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	button.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#544634")
	button.add_theme_stylebox_override("hover", hover)
	var focus: StyleBoxFlat = hover.duplicate() as StyleBoxFlat
	focus.border_color = STONE_GOLD
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _show_toast(message: String) -> void:
	if toast_label == null:
		return
	toast_label.text = message
	toast_timer = 4.2

func _nearest_interactable() -> Node3D:
	if player == null:
		return null
	var nearest: Node3D = null
	var nearest_distance: float = 2.65
	for target: Node3D in interactables:
		if not is_instance_valid(target) or not target.visible:
			continue
		if not _interaction_is_available(str(target.get_meta("target_id"))):
			continue
		var distance: float = player.global_position.distance_to(target.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = target
	return nearest

func _interaction_is_available(target_id: String) -> bool:
	var run: RunState = GameSession.state
	if target_id == "keeper":
		return (run.beat == RunState.Beat.PERSONAL_TASK and not run.keeper_task_talked) or (run.beat == RunState.Beat.RECORD_REQUEST and run.order_read and run.leader_response_heard and not run.keeper_response_heard) or run.beat == RunState.Beat.DECISION
	if target_id == "friend":
		return (run.beat == RunState.Beat.PERSONAL_TASK and not run.friend_task_talked) or run.consequence_shown
	if target_id == "rope_bundle":
		return run.beat == RunState.Beat.PERSONAL_TASK and run.keeper_task_talked and run.friend_task_talked and not run.rope_picked
	if target_id == "bell":
		return run.beat == RunState.Beat.PERSONAL_TASK and run.rope_picked
	if target_id == "leader":
		return run.beat == RunState.Beat.RECORD_REQUEST and run.order_read and not run.leader_response_heard
	if target_id == "letter":
		return run.beat == RunState.Beat.RECORD_REQUEST and run.visitor_request_heard and not run.order_read
	return target_id == "visitor" and (run.beat == RunState.Beat.RECORD_REQUEST or run.beat == RunState.Beat.DECISION)

func _interaction_prompt(target: Node3D) -> String:
	if target == null:
		return ""
	var target_id: String = str(target.get_meta("target_id"))
	if target_id == "bell":
		return _tr("INTERACT_BELL")
	if target_id == "rope_bundle":
		return _tr("INTERACT_ROPE")
	if target_id == "letter":
		return _tr("INTERACT_ORDER")
	return _tr("INTERACT_HINT")

func _find_target(target_id: String) -> Node3D:
	for target: Node3D in interactables:
		if is_instance_valid(target) and str(target.get_meta("target_id")) == target_id:
			return target
	return null

func _make_npc(target_id: String, label_key: String, at: Vector3, color: Color) -> void:
	var actor: Node3D = Node3D.new()
	actor.name = target_id.capitalize()
	actor.position = at
	actor.set_meta("target_id", target_id)
	interactables.append(actor)
	actor.add_to_group("interactables")
	var body: MeshInstance3D = _make_sphere_mesh(actor, Vector3(0, 0.9, 0), Vector3(0.72, 1.65, 0.72), color)
	_make_sphere_mesh(actor, Vector3(0, 1.93, 0), Vector3(0.48, 0.52, 0.48), Color("#c59b78"))
	_make_box_child(actor, Vector3(0, 0.8, -0.4), Vector3(0.8, 0.72, 0.2), color.darkened(0.15))
	if target_id == "keeper":
		keeper_cloak = body
	if target_id == "friend":
		friend_cape = body
		friend_actor = actor
	actor.set_meta("label_key", label_key)
	var nameplate: Label3D = Label3D.new()
	nameplate.text = _tr(label_key)
	nameplate.position.y = 2.55
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	nameplate.font_size = 30
	nameplate.outline_size = 6
	nameplate.modulate = Color("#f4e4c8")
	nameplate.visible = false
	actor.add_child(nameplate)
	add_child(actor)

func _move_companion(delta: float) -> void:
	var offset: Vector3 = player.global_basis.z * 1.8 + player.global_basis.x * 0.85
	var destination: Vector3 = player.global_position + offset
	destination.y = 0.0
	friend_actor.global_position = friend_actor.global_position.lerp(destination, delta * 2.0)
	var toward_player: Vector3 = player.global_position - friend_actor.global_position
	friend_actor.rotation.y = atan2(-toward_player.x, -toward_player.z)

func _make_interactable(target_id: String, at: Vector3, color: Color) -> void:
	var node: Node3D = Node3D.new()
	node.name = target_id.capitalize()
	node.position = at
	node.set_meta("target_id", target_id)
	interactables.append(node)
	add_child(node)
	if target_id == "bell":
		_make_cylinder_child(node, Vector3(0, 0.5, 0), Vector2(0.12, 1.0), Color("#8b6338"))
		_make_sphere_mesh(node, Vector3(0, 1.15, 0), Vector3(0.55, 0.68, 0.55), color)
	elif target_id == "rope_bundle":
		var coil: TorusMesh = TorusMesh.new()
		coil.inner_radius = 0.28
		coil.outer_radius = 0.38
		coil.rings = 8
		coil.ring_segments = 6
		var coil_mesh: MeshInstance3D = MeshInstance3D.new()
		coil_mesh.mesh = coil
		coil_mesh.position.y = 0.12
		coil_mesh.material_override = _material(color)
		node.add_child(coil_mesh)
	elif target_id == "letter":
		_make_box_child(node, Vector3(0, 0.7, 0), Vector3(1.25, 0.12, 0.85), Color("#725238"))
		_make_box_child(node, Vector3(-0.48, 0.35, -0.3), Vector3(0.12, 0.7, 0.12), Color("#594331"))
		_make_box_child(node, Vector3(0.48, 0.35, -0.3), Vector3(0.12, 0.7, 0.12), Color("#594331"))
		_make_box_child(node, Vector3(-0.48, 0.35, 0.3), Vector3(0.12, 0.7, 0.12), Color("#594331"))
		_make_box_child(node, Vector3(0.48, 0.35, 0.3), Vector3(0.12, 0.7, 0.12), Color("#594331"))
		_make_box_child(node, Vector3(0, 0.8, 0), Vector3(0.4, 0.02, 0.28), color)
	else:
		_make_box_child(node, Vector3(0, 0.5, 0), Vector3(0.7, 0.08, 0.5), color)
		_make_box_child(node, Vector3(0, 0.8, 0), Vector3(0.12, 0.55, 0.12), Color("#6f5237"))

func _make_box(at: Vector3, size: Vector3, color: Color, collision: bool) -> MeshInstance3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Village geometry"
	body.position = at
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _material(color)
	body.add_child(mesh)
	if collision:
		var collision_node: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = size
		collision_node.shape = shape
		body.add_child(collision_node)
	add_child(body)
	_last_mesh = mesh
	return mesh

func _make_box_child(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = at
	mesh.material_override = _material(color)
	parent.add_child(mesh)
	return mesh

func _make_cylinder(at: Vector3, radius: float, height: float, color: Color) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Village cylinder"
	body.position = at
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = 7
	mesh.mesh = cylinder
	mesh.material_override = _material(color)
	body.add_child(mesh)
	var collision_node: CollisionShape3D = CollisionShape3D.new()
	var shape: CylinderShape3D = CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision_node.shape = shape
	body.add_child(collision_node)
	add_child(body)

func _make_cylinder_child(parent: Node3D, at: Vector3, dimensions: Vector2, color: Color) -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = dimensions.x
	cylinder.bottom_radius = dimensions.x
	cylinder.height = dimensions.y
	cylinder.radial_segments = 7
	mesh.mesh = cylinder
	mesh.position = at
	mesh.material_override = _material(color)
	parent.add_child(mesh)

func _make_sphere(at: Vector3, size: Vector3, color: Color, segments: int = 6) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = segments
	sphere.rings = maxi(segments - 2, 2)
	mesh.mesh = sphere
	mesh.scale = size
	mesh.position = at
	mesh.material_override = _material(color)
	add_child(mesh)
	return mesh

func _make_sphere_mesh(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	sphere.radial_segments = 8
	sphere.rings = 6
	mesh.mesh = sphere
	mesh.position = at
	mesh.scale = size
	mesh.material_override = _material(color)
	parent.add_child(mesh)
	return mesh

func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	return material

func _tr(key: String) -> String:
	return tr(key.to_lower())
