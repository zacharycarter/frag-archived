import glm

type
  Vertex* = object
    position: Vec3[float32]
    uv: Vec2[float32]
    normal: Vec3[float32]
    tangent: Vec4[float32]
    color: array[4, uint8]
    blendIndices: array[4, uint8]
    blendWeights: array[4, uint8]