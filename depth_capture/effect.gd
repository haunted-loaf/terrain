@tool
extends CompositorEffect
class_name DepthCaptureCompositorEffect

signal captured;

var far: float
var target_tex: RID
var texture_size := Vector2(32, 32)
var shader: RID
var pipeline: RID
var sampler: RID
var rd: RenderingDevice

func _init() -> void:
  effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
  RenderingServer.call_on_render_thread(_init_compute)

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    if shader.is_valid():
      rd.free_rid(shader)

func _init_compute() -> void:
  rd = RenderingServer.get_rendering_device()
  if !rd: return
  
  var state := RDSamplerState.new()
  state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
  state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
  sampler = rd.sampler_create(state)
  
  var shader_file : RDShaderFile = load("res://depth_capture/effect.glsl")
  var spirv := shader_file.get_spirv()
  shader = rd.shader_create_from_spirv(spirv)
  pipeline = rd.compute_pipeline_create(shader)

func get_bytes() -> PackedByteArray:
  return rd.texture_get_data(target_tex, 0)

func _render_callback(effect_callback_type: int, render_data: RenderData) -> void:
  if not target_tex.is_valid(): return
  
  if rd and effect_callback_type == CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT:
    
    var buffers : RenderSceneBuffersRD = render_data.get_render_scene_buffers()
    if not buffers: return
    
    var size := buffers.get_internal_size()
    if size.x == 0 and size.y == 0: return
    
    var x_groups := (size.x - 1) / 8 + 1
    var y_groups := (size.y - 1) / 8 + 1
    
    var view_count := buffers.get_view_count()
    
    for view in range(view_count):
      var depth_tex := buffers.get_depth_layer(view)
      
      var depth_uniform := RDUniform.new()
      depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
      depth_uniform.binding = 0
      depth_uniform.add_id(sampler)
      depth_uniform.add_id(depth_tex)
      
      var depth_copy_uniform := RDUniform.new()
      depth_copy_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
      depth_copy_uniform.binding = 1
      depth_copy_uniform.add_id(target_tex)
      
      var params := PackedFloat32Array()
      params.push_back(texture_size.x)
      params.push_back(texture_size.y)
      params.push_back(far)
      
      var params_buffer := rd.storage_buffer_create(params.size() * 4, params.to_byte_array())
      
      var params_uniform := RDUniform.new()
      params_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
      params_uniform.binding = 2
      params_uniform.add_id(params_buffer)
      
      var uniform_set := rd.uniform_set_create([depth_uniform, depth_copy_uniform, params_uniform], shader, 0)
      
      var list := rd.compute_list_begin()
      rd.compute_list_bind_compute_pipeline(list, pipeline)
      rd.compute_list_bind_uniform_set(list, uniform_set, 0)
      rd.compute_list_dispatch(list, x_groups, y_groups, 1)
      rd.compute_list_end()
      
      rd.free_rid(uniform_set)
      
      captured.emit()
