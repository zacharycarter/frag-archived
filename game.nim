import camera, iqm, model, scene,
       glm

var 
  s: Scene
  c: FpsCamera
  level: Model
  dude: Model

proc init*(width, height: int) =
  s = newScene()
  s.setGravity(vec3(0.0'f32, -0.1'f32, 0.0'f32))

  c = newFpsCamera(0.0'f32, 0.0'f32, 0.0'f32, 0.1'f32, 70.0'f32, width, height)

  level = iqm.loadModelIQM(s, "data/level.iqm", {ilfKeepVertices})
  dude = iqm.loadModelIQM(s, "data/dude.iqm", {ilfKeepVertices})

proc update*(dt: float64) =
  s.update(dt)
  c.update()

proc draw*() =
  s.draw(0, 0, 0, 0, c.matrices)

proc shutdown*() =
  discard

proc keyPressed*(key: int) =
  discard

proc resized*(width, height: int) =
  discard