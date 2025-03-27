@tool
extends Node3D

@export var count := 1:
  set(value):
    if count != value:
      count = value
      dirty = true

@export var container: Node3D

@export var scale_factor := 3.0

@export var ring_template: PackedScene

@export var dirty = false

func _ready() -> void:
  dirty = true

func _process(delta: float) -> void:
  if dirty:
    dirty = false
    for child in container.get_children():
      child.queue_free()
    var ring_scale = Vector3.ONE
    for i in range(count):
      var ring := ring_template.instantiate() as Node3D
      container.add_child(ring)
      ring.scale = ring_scale
      ring_scale *= scale_factor
