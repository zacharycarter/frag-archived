import glm

type
  Bone* = object
    name*: string
    parent*: int
    position*, scale*: Vec3[float32]
    rotation*: Quat[float32]
    transform*: Mat4[float32]

  Model* = ref object