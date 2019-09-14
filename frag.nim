import os, tables,
       config, framebuffer, window,
       physfs, sdl2 as sdl

const fragDataFile = "data.frag"

var
  initProc*: proc()
  updateProc*: proc(dt: float64)
  drawProc*: proc()
  shutdownProc*: proc()

proc frag*() =
  let args = commandLineParams()

  discard PHYSFS_init(if len(args) > 0: args[0] else: "")
  discard PHYSFS_mount(fragDataFile, nil, 1)

  var deltaTime, accumulator = 0.0'f64
  
  let
    physDeltaTime = 1.0 / 60.0
    slowestFrame = 1.0 / 15.0
    conf = loadConfig("conf.ini")
    width = conf.entries["window_width"].i
    height = conf.entries["window_height"].i

  if not window.init(width, height, "frag"):
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
  
  window.destroy()
  discard PHYSFS_deinit()
  framebuffer.destroy()

  shutdownProc()