class_name Maths

static func point_in_circle(r: float) -> Vector2:
  var angle := randf_range(0, TAU)
  return Vector2(cos(angle), sin(angle)) * sqrt(randf()) * r

static func point_in_annulus(r1: float, r2: float) -> Vector2:
  var angle := randf_range(0, TAU)
  var dist := sqrt(randf() * (r1 ** 2 - r2 ** 2) + r2 ** 2)
  return Vector2(cos(angle), sin(angle)) * dist
