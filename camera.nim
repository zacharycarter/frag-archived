import math,
       model,
       glm

type
  CameraMatrices* = object
    view*, projection*, inverseView*: Mat4[float32]

  FpsCamera* = ref object
    position, front, up: Vec3[float32]
    yaw, pitch, lastX, lastY, fov, sensitivity: float32
    width, height: int
    update: bool
    viewModel: Model
    matrices*: CameraMatrices

proc update*(cam: FpsCamera) =
  if not cam.update:
    return

proc resize*(cam: FpsCamera; width, height: int) =
  if cam.width != width or cam.height != height:
    cam.matrices.projection = perspective(degToRad(cam.fov), float32(width) / float32(height), 0.01'f32, 1000.0'f32)
    cam.width = width
    cam.height = height

proc newFpsCamera*(x, y, z, sensitivity, fov: float32; width, height: int): FpsCamera =
  result = new FpsCamera

  result.position.x = x
  result.position.y = y
  result.position.z = z

  result.front.x = 0.0'f32
  result.front.y = 0.0'f32
  result.front.z = -1.0'f32

  result.up.x = 0.0'f32
  result.up.y = 1.0'f32
  result.up.z = 0.0'f32

  result.yaw = 0.0'f32
  result.pitch = 0.0'f32
  result.fov = fov
  result.sensitivity = sensitivity

  result.width = 0
  result.height = 0
  result.lastX = 0
  result.lastY = 0

  result.update = true

  result.matrices.view = mat4(1.0'f32)
  result.matrices.projection = mat4(1.0'f32)

  result.resize(width, height)