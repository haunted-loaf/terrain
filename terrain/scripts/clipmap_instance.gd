@tool
class_name ClipmapInstance
extends MeshInstance3D

@export var type: ClipmapBuilder.Type:
  set(value):
    if type == value:
      return
    type = value
    dirty = true

#@export var data: TerrainData:
#  set(value):
#    if data == value:
#      return
#    if data:
#      data.changed.disconnect(_on_data_changed)
#    data = value
#    if data:
#      data.changed.connect(_on_data_changed)
#    dirty = true

@export var dirty = false

var level: ClipmapLevel

#var terrain: ClipmapTerrain

var material: Material

static func make(level: ClipmapLevel, type: ClipmapBuilder.Type, scale: float):
  var instance = ClipmapInstance.new()
  instance.level = level
#  instance.terrain = terrain
#  instance.data = data
  instance.type = type
  instance.scale = Vector3(scale, 1, scale)
  instance.dirty = true
  return instance

func _process(_delta):
  set_layer_mask_value(2, true)
  set_instance_shader_parameter("extra_rotation_0", get_parent().global_transform.basis[0])
  set_instance_shader_parameter("extra_rotation_1", get_parent().global_transform.basis[1])
  set_instance_shader_parameter("extra_rotation_2", get_parent().global_transform.basis[2])
  if not dirty:
    return
  dirty = false
  update()

func update():
#  if not data or not terrain:
#    return
  mesh = level.terrain.get_mesh(type)
  extra_cull_margin = 16384
  self.ignore_occlusion_culling = true
  # var aabb := get_aabb()
  # aabb.size.y = 2 * data.world_height
  # custom_aabb = aabb
  material_override = material

func _on_data_changed():
  dirty = true
