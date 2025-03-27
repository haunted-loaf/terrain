@tool
extends Node3D
class_name TerrainOrigin

func _process(delta: float) -> void:
  RenderingServer.global_shader_parameter_set("_terrain_origin", global_position)
