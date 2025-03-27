@tool
class_name ClipmapLevel
extends Node3D

@export var dirty = false

@export var level: int = 0:
  set(value):
    if level != value:
      level = value
      dirty = true

var terrain: ClipmapTerrain

var follow: Node3D

var material: Material

var c : ClipmapInstance
var o : ClipmapInstance
var u : ClipmapInstance
var l : ClipmapInstance

func _process(_delta):
  if dirty:
    dirty = false
    for node in get_children(true):
      node.free()
    if level == 1:
      c = make_mesh(ClipmapBuilder.Type.CENTRE, level)
    else:
      c = make_mesh(ClipmapBuilder.Type.RING, level)
    o = make_mesh(ClipmapBuilder.Type.O, level)
    u = make_mesh(ClipmapBuilder.Type.U, level)
    l = make_mesh(ClipmapBuilder.Type.L, level)
  if not c or not o or not l or not u:
    return
  c.visible = true
  o.visible = false
  l.visible = false
  u.visible = false
  var pos1: Vector3 = snap(1)
  var pos2: Vector3 = snap(2)
  c.position = Vector3(pos1.x, position.y, pos1.z)
  o.position = Vector3(pos2.x, position.y, pos2.z)
  l.position = Vector3(pos2.x, position.y, pos2.z)
  u.position = Vector3(pos2.x, position.y, pos2.z)
  pos1 = global_transform.basis * pos1
  pos2 = global_transform.basis * pos2
  if pos1 == pos2:
    o.visible = true
  elif pos1.x == pos2.x || pos1.z == pos2.z:
    u.visible = true
    if pos1.x < pos2.x:
      u.rotation_degrees.y = 90
    elif pos1.x > pos2.x:
      u.rotation_degrees.y = -90
    elif pos1.z < pos2.z:
      u.rotation_degrees.y = 0
    elif pos1.z > pos2.z:
      u.rotation_degrees.y = 180
  else:
    l.visible = true
    if pos1.x < pos2.x && pos1.z < pos2.z:
      l.rotation_degrees.y = 0
    elif pos1.x < pos2.x && pos1.z > pos2.z:
      l.rotation_degrees.y = 90
    elif pos1.x > pos2.x && pos1.z < pos2.z:
      l.rotation_degrees.y = 270
    elif pos1.x > pos2.x && pos1.z > pos2.z:
      l.rotation_degrees.y = 180

func make_mesh(type: ClipmapBuilder.Type, level: float):
  var instance = ClipmapInstance.make(self, type, pow(2, level - 1))
  instance.name = str(type)
  instance.material = material
  add_child(instance, false, INTERNAL_MODE_BACK)
  # instance.set_owner(get_tree().edited_scene_root)
  return instance

func snap(bias: int) -> Vector3:
  var p := follow.global_position if follow else global_position
  p = global_transform.basis.inverse() * p
  var o := p.snapped(Vector3(bias * pow(2, level - 1), 0, bias * pow(2, level - 1)))
  return Vector3(o.x, p.y, o.z)
