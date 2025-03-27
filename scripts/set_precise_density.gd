@tool
extends WorldEnvironment

@export var rcpt = 1e6

func _process(delta: float) -> void:
  environment.fog_density = 1 / rcpt
