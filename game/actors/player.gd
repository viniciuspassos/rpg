class_name PlayerActor
extends CharacterBody3D

signal health_changed(current: int, maximum: int)
signal attacked
signal power_used
signal defeated

const WALK_SPEED: float = 5.4
const DODGE_SPEED: float = 10.5
const GRAVITY: float = 22.0
const PROTAGONIST_SCENE: PackedScene = preload("res://game/art/protagonist.glb")

var health: int = 100
var max_health: int = 100
var dodge_time: float = 0.0
var attack_cooldown: float = 0.0
var power_cooldown: float = 0.0
var invulnerable: bool = false
var power_unlocked: bool = false
var camera_pivot: Node3D
var camera: Camera3D
var camera_obstruction: RayCast3D
var camera_offset: Vector3 = Vector3(0.65, 2.0, 3.8)
var power_uses: int = 3
var protagonist_model: Node3D
var left_leg: Node3D
var right_leg: Node3D
var free_arm: Node3D
var weapon_rig: Node3D
var walk_time: float = 0.0
var arena_center: Vector2 = Vector2.ZERO
var arena_radii: Vector2 = Vector2.ZERO
var fixed_camera: bool = false

func _ready() -> void:
	_build_character()
	_build_camera()
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _build_character() -> void:
	var collision: CollisionShape3D = CollisionShape3D.new()
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)
	protagonist_model = PROTAGONIST_SCENE.instantiate() as Node3D
	protagonist_model.name = "Protagonist"
	protagonist_model.rotation.y = PI
	add_child(protagonist_model)
	left_leg = protagonist_model.find_child("Leg_L", true, false) as Node3D
	right_leg = protagonist_model.find_child("Leg_R", true, false) as Node3D
	free_arm = protagonist_model.find_child("Arm_R", true, false) as Node3D
	weapon_rig = protagonist_model.find_child("Arm_L", true, false) as Node3D
	set_protagonist_presentation(str(GameSession.state.protagonist))

func _build_camera() -> void:
	camera_pivot = Node3D.new()
	get_parent().add_child(camera_pivot)
	camera_pivot.global_position = global_position + Vector3(0, 1.35, 0)
	camera_obstruction = RayCast3D.new()
	camera_obstruction.target_position = camera_offset
	camera_obstruction.add_exception(self)
	camera_pivot.add_child(camera_obstruction)
	camera = Camera3D.new()
	camera.position = camera_offset
	camera.rotation.x = deg_to_rad(-22.0)
	camera.current = true
	camera.fov = 54.0
	camera_pivot.add_child(camera)

func _physics_process(delta: float) -> void:
	if not fixed_camera:
		camera_pivot.global_position = global_position + Vector3(0, 1.35, 0)
		camera_pivot.rotate_y(-Input.get_axis("look_left", "look_right") * delta * 1.8)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - Input.get_axis("look_up", "look_down") * delta * 1.4, deg_to_rad(-48.0), deg_to_rad(12.0))
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	power_cooldown = maxf(power_cooldown - delta, 0.0)
	dodge_time = maxf(dodge_time - delta, 0.0)
	invulnerable = dodge_time > 0.0
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera_basis: Basis = camera_pivot.global_basis
	var direction: Vector3 = camera_basis.x * input_vector.x + camera_basis.z * input_vector.y
	direction.y = 0.0
	direction = direction.normalized()
	var speed: float = DODGE_SPEED if dodge_time > 0.0 else WALK_SPEED
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 12.0)
	move_and_slide()
	constrain_to_arena()
	animate_protagonist(delta, Vector2(velocity.x, velocity.z).length() / WALK_SPEED)
	if not fixed_camera:
		_update_camera_clearance()
	if Input.is_action_just_pressed("dodge") and is_on_floor():
		dodge_time = 0.32
	if Input.is_action_just_pressed("attack"):
		_attack()
	if Input.is_action_just_pressed("power") and power_unlocked and power_uses > 0 and power_cooldown <= 0.0:
		_use_power()

func constrain_to_arena() -> void:
	if arena_radii.x <= 0.0 or arena_radii.y <= 0.0:
		return
	var offset: Vector2 = Vector2(global_position.x, global_position.z) - arena_center
	var normalized: Vector2 = Vector2(offset.x / arena_radii.x, offset.y / arena_radii.y)
	if normalized.length_squared() <= 1.0:
		return
	normalized = normalized.normalized()
	global_position.x = arena_center.x + normalized.x * arena_radii.x
	global_position.z = arena_center.y + normalized.y * arena_radii.y
	velocity.x = 0.0
	velocity.z = 0.0

func _update_camera_clearance() -> void:
	camera_obstruction.force_raycast_update()
	if camera_obstruction.is_colliding():
		camera.global_position = camera_obstruction.get_collision_point() + camera_obstruction.get_collision_normal() * 0.15
	else:
		camera.position = camera_offset

func animate_protagonist(delta: float, movement: float) -> void:
	var stride: float = clampf(movement, 0.0, 1.0)
	walk_time += delta * (8.0 if stride > 0.05 else 2.0)
	var swing: float = sin(walk_time) * 0.36 * stride
	left_leg.rotation.x = swing
	right_leg.rotation.x = -swing
	free_arm.rotation.x = -swing * 0.55
	if attack_cooldown <= 0.0:
		weapon_rig.rotation.x = swing * 0.45
	protagonist_model.position.y = absf(sin(walk_time)) * 0.025 * stride

func set_protagonist_presentation(protagonist: String) -> void:
	var bun: Node3D = protagonist_model.find_child("low bun", true, false) as Node3D
	var bun_facet: Node3D = protagonist_model.find_child("bun light facet", true, false) as Node3D
	if bun != null:
		bun.visible = protagonist == "female"
	if bun_facet != null:
		bun_facet.visible = protagonist == "female"
	var blue: StandardMaterial3D = StandardMaterial3D.new()
	blue.albedo_color = Color("#355879")
	blue.roughness = 0.9
	for cloak_name: String in ["red shoulder mantle", "cloak tail"]:
		var cloak: MeshInstance3D = protagonist_model.find_child(cloak_name, true, false) as MeshInstance3D
		if cloak != null:
			cloak.material_override = blue if protagonist == "male" else null

func reset_for_fresh_run() -> void:
	health = max_health
	velocity = Vector3.ZERO
	dodge_time = 0.0
	attack_cooldown = 0.0
	power_cooldown = 0.0
	power_uses = 3
	power_unlocked = false
	invulnerable = false
	walk_time = 0.0
	left_leg.rotation.x = 0.0
	right_leg.rotation.x = 0.0
	free_arm.rotation.x = 0.0
	weapon_rig.rotation.x = 0.0
	protagonist_model.position.y = 0.0
	health_changed.emit(health, max_health)

func _attack() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.62
	weapon_rig.rotation.x = deg_to_rad(62.0)
	var swing: Tween = create_tween()
	swing.tween_property(weapon_rig, "rotation:x", 0.0, 0.13).set_ease(Tween.EASE_OUT)
	attacked.emit()
	var target: Node = _nearest_target("enemy", 2.8)
	if target != null and target.has_method("take_damage"):
		target.call("take_damage", 34)

func _use_power() -> void:
	power_uses -= 1
	power_cooldown = 1.0
	power_used.emit()
	var target: Node = _nearest_target("power_target", 7.0)
	if target != null and target.has_method("receive_power"):
		target.call("receive_power")

func _nearest_target(group_name: String, radius: float) -> Node:
	var nearest: Node = null
	var nearest_distance: float = radius
	for candidate: Node in get_tree().get_nodes_in_group(group_name):
		if not candidate is Node3D:
			continue
		var target: Node3D = candidate as Node3D
		var distance: float = global_position.distance_to(target.global_position)
		var forward: Vector3 = -global_basis.z
		var toward: Vector3 = (target.global_position - global_position).normalized()
		if distance < nearest_distance and forward.dot(toward) > 0.05:
			nearest_distance = distance
			nearest = candidate
	return nearest

func take_damage(amount: int) -> void:
	if invulnerable or health <= 0:
		return
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		defeated.emit()
