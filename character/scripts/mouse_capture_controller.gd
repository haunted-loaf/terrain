extends Node

var mouse_position: Vector2

var captured: bool:
  get: return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
  capture()

func toggle() -> void:
  if captured:
    release()
  else:
    capture()

func release() -> void:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  Input.warp_mouse(mouse_position)

func capture() -> void:
  mouse_position = get_viewport().get_mouse_position()
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
  if Input.is_action_just_pressed("mode_free_cursor"):
    toggle()
