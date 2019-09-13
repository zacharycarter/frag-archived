import framebuffer, window,
       sdl2 as sdl

var
  initProc*: proc()
  updateProc*: proc(dt: float64)
  drawProc*: proc()
  shutdownProc*: proc()

proc frag*() =
  var deltaTime, accumulator = 0.0'f64
  
  let
    physDeltaTime = 1.0 / 60.0
    slowestFrame = 1.0 / 15.0

  if not window.init(960, 540, "frag"):
    return

  framebuffer.init()

  initProc()

  var 
    lastFrameTime = float64(sdl.getPerformanceCounter())
    running = true
  
  while running:
    var currentFrameTime = float64(sdl.getPerformanceCounter())
    deltaTime = float64(currentFrameTime - lastFrameTime) / float64(sdl.getPerformanceFrequency())
    lastFrameTime = currentFrameTime

    if deltaTime > slowestFrame:
      deltaTime = slowestFrame

    accumulator += deltaTime
    while accumulator >= physDeltaTime:
      var event = sdl.defaultEvent
      while sdl.pollEvent(event):
        case event.kind
        of sdl.QuitEvent:
          running = false
        else:
          discard
    
      updateProc(physDeltaTime)
    
      accumulator -= physDeltaTime
  
    drawProc()
  
  shutdownProc()