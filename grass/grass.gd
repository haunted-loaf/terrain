@tool
extends MultiMeshInstance3D
class_name TerrainGrass

@export var dirty = false
@export var count = 10
@export var size = 1.0
@export var focus: Node3D
@export var depth_capture: DepthCaptureController
@export var texture : Texture2DRD
@export var visualiser : MeshInstance3D

func _process(_delta: float) -> void:
 
  if not focus: return
  if not texture: return
  
  global_position = focus.global_position.snapped(Vector3.ONE) * Vector3(1, 0, 1)
  depth_capture.global_position = global_position + Vector3(0, 100, 0)
  if depth_capture and depth_capture.texture and depth_capture.texture.is_valid():
    texture.texture_rd_rid = depth_capture.texture
    visualiser.material_override.set_shader_parameter("tex", texture)
    (material_override as ShaderMaterial).set_shader_parameter("heightmap", texture)

  if not dirty: return

  dirty = false
  multimesh.instance_count = count * count
  var i := 0
  for x in count:
    for z in count:
      var p := Vector3(x - count / 2.0, 0, z - count / 2.0)
      p /= count
      p *= size
      multimesh.set_instance_transform(i, Transform3D.IDENTITY.translated(p))
      multimesh.set_instance_custom_data(i, Color(x / float(count), z / float(count), 0, 0))
      i += 1
