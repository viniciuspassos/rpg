class_name GuardActor
extends CharacterBody3D

signal defeated

var health: int = 68
var attack_timer: float = 0.0
var flash_timer: float = 0.0
var target: PlayerActor
var body_material: StandardMaterial3D

func _ready() -> void:
	_build_guard()
	add_to_group("enemy")

func _build_guard() -> void:
	var shape_node: CollisionShape3D = CollisionShape3D.new()
	var shape: CapsuleShape3D = CapsuleShape3D.new()
	shape.radius = 0.43
	shape.height = 1.85
	shape_node.shape = shape
	shape_node.position.y = 0.93
	add_child(shape_node)
	var mesh_node: MeshInstance3D = MeshInstance3D.new()
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = 0.43
	mesh.height = 1.85
	mesh_node.mesh = mesh
	mesh_node.position.y = 0.93
	body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color("#8a4235")
	mesh_node.material_override = body_material
	add_child(mesh_node)
	var helm: MeshInstance3D = MeshInstance3D.new()
	_add_head(helm)

func _add_head(helm: MeshInstance3D) -> void:
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.3
	head_mesh.height = 0.6
	helm.mesh = head_mesh
	helm.position = Vector3(0, 1.95, 0)
	var head_material: StandardMaterial3D = StandardMaterial3D.new()
	head_material.albedo_color = Color("#b88d68")
	helm.material_override = head_material
	add_child(helm)

func _physics_process(delta: float) -> void:
	if target == null:
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target = players[0] as PlayerActor
			return
	if target == null or health <= 0:
		return
	attack_timer = maxf(attack_timer - delta, 0.0)
	flash_timer = maxf(flash_timer - delta, 0.0)
	body_material.albedo_color = Color("#e3ad70") if flash_timer > 0.0 else Color("#8a4235")
	var offset: Vector3 = target.global_position - global_position
	offset.y = 0.0
	var distance: float = offset.length()
	if distance > 1.65:
		velocity.x = offset.normalized().x * 2.0
		velocity.z = offset.normalized().z * 2.0
		rotation.y = atan2(-offset.x, -offset.z)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		if attack_timer <= 0.0:
			attack_timer = 2.2
			target.take_damage(8)
	if not is_on_floor():
		velocity.y -= 22.0 * delta
	else:
		velocity.y = -0.5
	move_and_slide()

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health = maxi(health - amount, 0)
	flash_timer = 0.16
	if health == 0:
		defeated.emit()
		queue_free()
