proc init*() =
  echo "initialized"

proc update*(dt: float64) =
  echo "updating"

proc draw*() =
  echo "drawing"

proc shutdown*() =
  echo "shutting down"

proc keyPressed*(key: int) =
  discard

proc resized*(width, height: int) =
  discard