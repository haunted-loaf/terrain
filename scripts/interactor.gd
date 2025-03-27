extends RayCast3D

@export var menu: VBoxContainer
@export var last_highlighted: Array[Interactable] = []

func _ready() -> void:
  pass

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("interact"):
    if len(last_highlighted) > 0:
      last_highlighted[0].perform()

func _process(delta: float) -> void:
  for c in menu.get_children(): c.queue_free()
  clear_exceptions()
  force_raycast_update()
  for l in last_highlighted:
    l.unhighlight()
  last_highlighted = []
  while is_colliding():
    var a := get_collider()
    if a is Interactable:
      var b := a as Interactable
      var l := Label.new()
      l.text = b.label
      menu.add_child(l)
      a.highlight()
      last_highlighted.push_back(a)
    break
    add_exception(a)
    force_raycast_update()
