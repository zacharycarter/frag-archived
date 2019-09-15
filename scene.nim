import math,
       framebuffer,
       glm

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

proc update*(scene: Scene; deltaTime: float32) =
  discard
  
proc setGravity*(scene: Scene; gravity: Vec3[float32]) =
  scene.gravity = gravity

proc newScene*(flags: SceneFlags = {}): Scene =
  result = new Scene

  result.framebuffer = newFramebuffer(0, 0)

proc destroy*(scene: Scene) =
  discard
