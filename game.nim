import scene

var s: Scene

proc init*() =
  s = newScene()

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