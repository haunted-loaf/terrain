@tool
class_name ClipmapTerrain
extends Node3D

@export var follow: Marker3D

@export var resolution = 1:
  set(value):
    if resolution != value:
      resolution = value
      meshes = {}
      dirty = true

@export var count: int = 1:
  set(value):
    value = clamp(value, 1, 30)
    if count != value:
      count = value
      dirty = true

@export var material: Material:
  set(value):
    if material != value:
      material = value
      dirty = true

@export var dirty = false

var meshes = {}

func _ready():
  dirty = true

func _process(_delta):
  if not is_visible_in_tree():
    return
  if dirty:
    dirty = false
    for node in get_children(true):
      node.queue_free()
    for i in count:
      var level := ClipmapLevel.new()
      level.terrain = self
      level.level = i + 1
      level.material = material
      level.follow = follow
      add_child(level)

func get_mesh(type: ClipmapBuilder.Type) -> ArrayMesh:
  if not meshes.has(type):
    meshes[type] = generate(type)
  return meshes[type]

func generate(type: ClipmapBuilder.Type) -> ArrayMesh:
  return ClipmapBuilder.new(resolution, type).build()
