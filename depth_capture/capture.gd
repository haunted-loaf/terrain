@tool
extends Node3D
class_name DepthCaptureController

signal captured

@export var camera: Camera3D
@export var effect: DepthCaptureCompositorEffect
@export var dirty := false

var texture: RID

func _ready() -> void:
  await get_tree().process_frame
  await get_tree().process_frame
  await get_tree().process_frame
  dirty = true
  effect.captured.connect(func(): captured.emit())

func _process(delta: float) -> void:
  if dirty:
    dirty = false
    camera.compositor.compositor_effects[0] = effect
    var rd := RenderingServer.get_rendering_device()
    var fmt := RDTextureFormat.new()
    fmt.format = RenderingDevice.DATA_FORMAT_R16_SFLOAT
    fmt.width = 32
    fmt.height = 32
    fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
    texture = rd.texture_create(fmt, RDTextureView.new())
    effect.far = camera.far
    effect.target_tex = texture
