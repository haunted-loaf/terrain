@tool
extends Node3D
class_name TerrainShape

@export_node_path("Node3D") var follow

@export var collider : CollisionShape3D

@export var resolution := 8:
  set(value):
    if resolution != value:
      resolution = value
      dirty = true

@export var dirty := false

@export var texture: RID

@export var sub_viewport: SubViewport

@export var fudge := 0.5:
  set(value):
    if fudge != value:
      fudge = value
      dirty = true

@export var camera_3d: Camera3D

var image: Image

var target_position: Vector3

var effect: DepthCaptureCompositorEffect

var data: PackedByteArray

func _ready() -> void:
  await get_tree().process_frame
  await get_tree().process_frame
  await get_tree().process_frame
  dirty = true

func _process(_delta: float) -> void:
  target_position = get_node(follow).global_position as Vector3 if has_node(follow) else global_position
  target_position.y = 0
  target_position = target_position.snapped(Vector3(1, 1, 1))
  if target_position != global_position:
    dirty = true
  if dirty:
    dirty = false
    camera_3d.global_position = target_position + Vector3(0, 100, 0)
    generate()

func generate() -> void:
  var rd := RenderingServer.get_rendering_device()
  var fmt := RDTextureFormat.new()
  fmt.format = RenderingDevice.DATA_FORMAT_R16_SFLOAT
  fmt.width = 32
  fmt.height = 32
  fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
  texture = rd.texture_create(fmt, RDTextureView.new())
  #mesh_instance_3d.material_override.albedo_texture.texture_rd_rid = texture
  effect = camera_3d.compositor.compositor_effects[0]
  effect.target_tex = texture
  
  await effect.captured
  
  global_position = target_position
  
  update()
  

func update() -> void:
  if not effect: return
  
  var bytes := effect.get_bytes()
  
  var hshape := collider.shape as HeightMapShape3D
  hshape.map_width = resolution
  hshape.map_depth = resolution
  
  var array := hshape.map_data
  
  var i := 0
  for x in range(resolution):
    for y in range(resolution):
      var h := bytes.decode_half(i * 2) + fudge
      array[i] = h
      i += 1

  hshape.map_data = array
