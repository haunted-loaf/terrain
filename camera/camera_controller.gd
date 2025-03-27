extends Camera3D

@export var focus: Node3D
@export var turn_speed := 0.1
@export var pitch: float
@export var yaw: float
@export var dolly := 1.0
@export var dolly_speed := 1.0
@export var dolly_min := 1.0
@export var dolly_max := 10.0
@export var dolly_base := 5.0
@export var dolly_exponent := 2.0

func _unhandled_input(event: InputEvent) -> void:
  if MouseCapture.captured:
    if event is InputEventMouseMotion:
      var yx_turn := (event as InputEventMouseMotion).relative
      var turn := Vector3(yx_turn.y, yx_turn.x, 0)
      #var turn_speed = self.turn_speed * lerp(1.0, 1.0 / 180.0, target_zoom if aiming else 0.0)
      #var turn_speed = self.turn_speed * (target_zoom * 0.01 if aiming else 1.0)
      pitch = clamp(pitch + turn.x * -turn_speed, -89, 89)
      yaw += turn.y * -turn_speed
    if event.is_action_pressed("zoom_in"):
      dolly = clamp(dolly - dolly_speed, dolly_min, dolly_max)
    if event.is_action_pressed("zoom_out"):
      dolly = clamp(dolly + dolly_speed, dolly_min, dolly_max)

func _process(delta: float) -> void:
  global_position = focus.global_position
  global_rotation = focus.global_rotation
  rotation_degrees.y = yaw
  rotation_degrees.x = pitch
  translate(Vector3.BACK * dolly_base * pow(dolly_exponent, dolly))
