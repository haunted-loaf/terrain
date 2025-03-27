@tool
extends DirectionalLight3D

@export var exponent := 2.0

func _process(delta: float) -> void:
  directional_shadow_split_1 = pow(exponent, -3)
  directional_shadow_split_2 = pow(exponent, -2)
  directional_shadow_split_3 = pow(exponent, -1)
