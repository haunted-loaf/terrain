extends Node
class_name CharacterController

@export var move_speed = 5.0
@export var move_accel = 20.0
@export var jump_accel = 5.0
@export var turn_speed = 0.1

@export var body: CharacterBody3D
@export var head: Node3D

var jumping: bool
var motion: Vector3

func _ready() -> void:
  body.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

func _unhandled_input(event: InputEvent) -> void:
  if MouseCapture.captured and event is InputEventMouseMotion:
    var yx_turn = (event as InputEventMouseMotion).relative
    var turn = Vector3(yx_turn.y, yx_turn.x, 0)
    head.rotation_degrees.x += -turn.x * turn_speed
    head.rotation_degrees.x = clamp(head.rotation_degrees.x, -80, 80)
    body.rotation_degrees.y += -turn.y * turn_speed

func _process(_delta: float) -> void:
  var xz_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
  var y_dir := Input.get_axis("move_down", "move_up")
  var dir := Vector3(xz_dir.x, y_dir, xz_dir.y)
  dir *= move_speed
  dir = body.global_transform.basis * dir
  motion = dir
  jumping = Input.is_action_just_pressed("jump")

func _physics_process(delta: float) -> void:
  if body.is_on_floor():
    body.velocity = body.velocity.move_toward(motion, delta * move_accel)
    if jumping:
      body.velocity.y += jump_accel
  else:
    var y := body.velocity.y
    body.velocity = body.velocity.move_toward(motion, delta * move_accel)
    body.velocity.y = y
    body.velocity += ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity") * delta
  body.move_and_slide()
