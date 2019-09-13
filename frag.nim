import framebuffer, window,
       sdl2 as sdl

const
  physDeltaTime = 1.0 / 60.0
  slowestFrame = 1.0 / 15.0

var
  deltaTime, accumulator: float64

proc frag() =
  if not window.init(960, 540, "frag"):
    return

  framebuffer.init()

  var 
    lastFrameTime = sdl.getPerformanceCounter()
    running = true
    e: sdl.Event
  
  while running:
    var currentFrameTime = sdl.getPerformanceCounter()
    deltaTime = float64(currentFrameTime - lastFrameTime) / float64(sdl.getPerformanceCounter())
    lastFrameTime = currentFrameTime

    if deltaTime > slowestFrame:
      deltaTime = slowestFrame

    accumulator += deltaTime
    while accumulator >= physDeltaTime:
      while sdl.pollEvent(e):
        case e.kind
        of sdl.QuitEvent:
          running = false
        else:
          discard
    
    accumulator -= physDeltaTime

frag()