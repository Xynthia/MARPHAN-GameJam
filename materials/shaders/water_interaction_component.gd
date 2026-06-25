extends Node3D
# Feeds the world positions of tracked objects to add a ring of foam around them
# The Compatibility renderer cannot read the depth buffer

@export var MAX_INTERACTIONS: int = 16

@export var tracked_objects: Array[Node3D] = []
@export var foam_radius: float = 0.2
@export var pulse_amount: float = 0.1
@export var pulse_speed: float = 1.2

var _material: ShaderMaterial
var _positions: PackedVector3Array = PackedVector3Array()
var _radii: PackedFloat32Array = PackedFloat32Array()
var _time: float = 0.0

func _ready() -> void:
	_positions.resize(MAX_INTERACTIONS)
	_radii.resize(MAX_INTERACTIONS)
	_grab_material()
	if _material == null:
		push_warning("water_interaction_component found no ShaderMaterial, it must be a child of the water MeshInstance3D")

func _grab_material() -> void:
	var mesh: MeshInstance3D = get_parent() as MeshInstance3D
	if mesh == null:
		return
	var mat: Material = mesh.get_active_material(0)
	if mat == null:
		mat = mesh.material_override
	if mat is ShaderMaterial:
		_material = mat as ShaderMaterial

func _process(delta: float) -> void:
	if _material == null:
		_grab_material()
		if _material == null:
			return
	_time += delta
	_push_interactions()

func _push_interactions() -> void:
	var active: int = mini(tracked_objects.size(), MAX_INTERACTIONS)
	for i in MAX_INTERACTIONS:
		if i < active and is_instance_valid(tracked_objects[i]):
			_positions[i] = tracked_objects[i].global_position
			# smooth per object pulse, sine over time
			var pulse: float = 1.0 + pulse_amount * sin(_time * pulse_speed + float(i) * 1.7)
			_radii[i] = foam_radius * pulse
		else:
			_positions[i] = Vector3.ZERO
			_radii[i] = 0.0
	_material.set_shader_parameter("interaction_count", active)
	_material.set_shader_parameter("interaction_pos", _positions)
	_material.set_shader_parameter("interaction_radius", _radii)
