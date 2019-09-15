import camera, scene,
       glm

var 
  s: Scene
  c: FpsCamera

proc init*(width, height: int) =
  s = newScene()
  s.setGravity(vec3(0.0'f32, -0.1'f32, 0.0'f32))

  c = newFpsCamera(0.0'f32, 0.0'f32, 0.0'f32, 0.1'f32, 70.0'f32, width, height)

proc update*(dt: float64) =
  s.update(dt)
  c.update()

proc draw*() =
  discard

proc shutdown*() =
  discard

proc keyPressed*(key: int) =
  discard

proc resized*(width, height: int) =
  discard