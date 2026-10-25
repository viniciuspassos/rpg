class_name PlayerActor
extends CharacterBody3D

signal health_changed(current: int, maximum: int)
signal attacked
signal power_used
signal defeated

const WALK_SPEED: float = 5.4
const DODGE_SPEED: float = 10.5
const GRAVITY: float = 22.0

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
var mantle_material: StandardMaterial3D
var weapon_rig: Node3D
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
	var body: MeshInstance3D = MeshInstance3D.new()
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = 0.42
	mesh.height = 1.8
	body.mesh = mesh
	body.position.y = 0.9
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color("#253442")
	material.metallic = 0.12
	body.material_override = material
	add_child(body)
	var mantle: MeshInstance3D = MeshInstance3D.new()
	var mantle_mesh: BoxMesh = BoxMesh.new()
	mantle_mesh.size = Vector3(0.82, 0.75, 0.24)
	mantle.mesh = mantle_mesh
	mantle.position = Vector3(0, 1.05, -0.24)
	mantle_material = StandardMaterial3D.new()
	mantle_material.albedo_color = Color("#9b4934")
	mantle.material_override = mantle_material
	add_child(mantle)
	_build_weapon()
	set_protagonist_presentation(str(GameSession.state.protagonist))

func _build_weapon() -> void:
	weapon_rig = Node3D.new()
	weapon_rig.position = Vector3(0.42, 0.72, -0.12)
	add_child(weapon_rig)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blade_mesh: BoxMesh = BoxMesh.new()
	blade_mesh.size = Vector3(0.11, 0.09, 1.15)
	blade.mesh = blade_mesh
	blade.position.z = -0.68
	blade.material_override = _weapon_material(Color("#b8c1c2"), 0.68)
	weapon_rig.add_child(blade)
	var guard: MeshInstance3D = MeshInstance3D.new()
	var guard_mesh: BoxMesh = BoxMesh.new()
	guard_mesh.size = Vector3(0.42, 0.09, 0.12)
	guard.mesh = guard_mesh
	guard.position.z = -0.12
	guard.material_override = _weapon_material(Color("#b28a4e"), 0.52)
	weapon_rig.add_child(guard)
	var grip: MeshInstance3D = MeshInstance3D.new()
	var grip_mesh: BoxMesh = BoxMesh.new()
	grip_mesh.size = Vector3(0.12, 0.34, 0.12)
	grip.mesh = grip_mesh
	grip.position.z = 0.08
	grip.material_override = _weapon_material(Color("#45352e"), 0.9)
	weapon_rig.add_child(grip)

func _weapon_material(color: Color, metallic: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.3
	return material

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

func set_protagonist_presentation(protagonist: String) -> void:
	mantle_material.albedo_color = Color("#9b4934") if protagonist == "female" else Color("#355879")

func reset_for_fresh_run() -> void:
	health = max_health
	velocity = Vector3.ZERO
	dodge_time = 0.0
	attack_cooldown = 0.0
	power_cooldown = 0.0
	power_uses = 3
	power_unlocked = false
	invulnerable = false
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
