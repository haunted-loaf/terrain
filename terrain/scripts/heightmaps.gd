@tool
extends Node3D

@export var material: ShaderMaterial

func _process(delta: float) -> void:
  var origins : Array[Transform3D] = []
  var maps : Array[Texture2D] = []
  for child: HeightmapMarker in get_children():
    if child.visible:
      origins.push_back(child.global_transform)
      maps.push_back(child.heightmap)
  if material:
    material.set_shader_parameter("_origins", origins)
    material.set_shader_parameter("_heightmaps", maps)
    material.set_shader_parameter("_origins_count", len(origins))
