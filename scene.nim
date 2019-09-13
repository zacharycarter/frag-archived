import math

const
  maxPointLights = 500
  maxSpotLights = 128
  maxReflections = 50

  maxLights = 500

  maxModels = 500

type
  SceneFlag = enum
    sfSSAO
    sfDeferred
  
  SceneFlags = set[SceneFlag]

  Scene = ref object
    ssao: bool
    deferred: bool

proc newScene*(flags: SceneFlags): Scene =
  result = new Scene

  result.framebuffer = newFramebuffer(0, 0)
