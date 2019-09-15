import camera, scene

var 
  s: Scene
  c: FpsCamera

proc init*() =
  s = newScene()

  c = newFpsCamera(0.0'f32, 0.0'f32, 0.0'f32, 0.1'f32, 70.0'f32)

proc update*(dt: float64) =
  discard

proc draw*() =
  discard

proc shutdown*() =
  discard

proc keyPressed*(key: int) =
  discard

proc resized*(width, height: int) =
  discard