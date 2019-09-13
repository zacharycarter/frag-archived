import math,
       framebuffer

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

proc newScene*(flags: SceneFlags = {}): Scene =
  result = new Scene

  result.framebuffer = newFramebuffer(0, 0)

proc destroy*(scene: Scene) =
  discard
