import math,
       camera, framebuffer, shader, window,
       bgfxdotnim, glm, sdl2 as sdl

const
  maxPointLights = 500
  maxSpotLights = 128
  maxReflections = 50

  maxLights = 500

  maxModels = 500

type
  SceneFlag* = enum
    sfSSAO
    sfDeferred
    sfCount
  
  SceneFlags* = set[SceneFlag]

  Scene* = ref object
    ssao: bool
    deferred: bool
    framebuffer: Framebuffer
    gravity: Vec3[float32]
    forwardShader, defaultShader: bgfx_program_handle_t

proc renderDepthMaps(s: Scene) =
  discard

proc renderForward(s: Scene; viewX, viewY, viewWidth, viewHeight: int; matrices: var CameraMatrices) =
  var vw, vh: cint
  sdl.getSize(display.windowPtr, vw, vh)

  var 
    width = if viewWidth == 0: int(vw) else: viewWidth
    height = if viewHeight == 0: int(vh) else: viewHeight
  
  s.renderDepthMaps()

  s.framebuffer.`bind`()

  bgfx_set_view_transform(0, addr matrices.view[0], addr matrices.projection[0])

  s.framebuffer.draw(vw, vh)

proc draw*(s: Scene; viewX, viewY, viewWidth, viewHeight: int; matrices: var CameraMatrices) =
  s.renderForward(viewX, viewY, viewWidth, viewHeight, matrices)

proc update*(sizeof: Scene; deltaTime: float32) =
  discard
  
proc setGravity*(s: Scene; gravity: Vec3[float32]) =
  s.gravity = gravity

proc newScene*(flags: SceneFlags = {}): Scene =
  result = new Scene

  result.framebuffer = newFramebuffer(0, 0)

  result.forwardShader = loadProgram("vs_forward", "fs_forward")
  result.defaultShader = result.forwardShader

proc destroy*(s: Scene) =
  discard
