import memfiles, strutils,
       cache, mesh, model, scene

type
  IQMLoadingFlag* = enum
    ilfKeepVertices
  
  IQMLoadingFlags* = set[IQMLoadingFlag]

  IQMHeader = object
    magic: array[16, char]
    version: uint32
    filesize: uint32
    flags: uint32
    numText, ofsText: uint32
    numMeshes, ofsMeshes: uint32
    numVertexArrays, numVertices, ofsVertexArrays: uint32
    numTriangles, ofsTriangles, ofsAdjacency: uint32
    numJoints, ofsJoints: uint32
    numPoses, ofsPoses: uint32
    numAnims, ofsAnims: uint32
    numFrames, numFrameChannels, ofsFrames, ofsBounds: uint32
    numComment, ofsComment: uint32
    numExtensions, ofsExtensions: uint32

  IQMMesh = object
    name: uint32
    material: uint32
    firstVertex, numVertices: uint32
    firstTriangle, numTriangles: uint32
  
  IQMVertexArray = object
    kind: IQMVertexArrrayKind
    flags: uint32
    format: uint32
    size: uint32
    offset: uint32

  IQMJoint = object
    name: uint32
    parent: int32
    translate: array[3, float32]
    rotate: array[4, float32]
    scale: array[3, float32]

  IQMVertexArrrayKind {. size: sizeof(cint) .} = enum
    vakPosition = 0
    vakTexcoord = 1
    vakNormal = 2
    vakTangent = 3
    vakBlendIndices = 4
    vakBlendWeights = 5
    vakColor = 6
    vakCustom = 0x10


const
  iqmMagic = ['I', 'N', 'T', 'E', 'R', 'Q', 'U', 'A', 'K', 'E', 'M', 'O', 'D', 'E', 'L', '\x00']
  iqmVersion = 2

proc loadModelIQM*(s: Scene; path: string, flags: IQMLoadingFlags): Model =
  let cached = cache.getModel(path)
  if cached != nil:
    return cached
  
  echo "Loading IQM model file $1\n" % path

  var data = memfiles.open(path)
  if data.mem == nil:
    echo "Failed to load IQM model file $1\n" % path
    return nil
  
  
  let header = cast[ptr IQMHeader](data.mem)
  if header.magic != iqmMagic or header.version != iqmVersion:
    echo "Loaded IQM model version is not 2.0\nFailed loading $1\n" % path
    data.close()
    return nil
  
  let meshes = cast[ptr UncheckedArray[IQMMesh]](cast[pointer](cast[int](header) + header.ofsMeshes.int))
  var fileText = if header.ofsText > 0'u32: cast[cstring](cast[pointer](cast[int](header) + header.ofsText.int)) else: ""

  var vertices = newSeq[Vertex](header.numVertices)
  var
    position: ptr UncheckedArray[float32]
    uv: ptr UncheckedArray[float32]
    normal: ptr UncheckedArray[float32]
    tangent: ptr UncheckedArray[float32]

    blendIndices: ptr UncheckedArray[uint8]
    blendWeights: ptr UncheckedArray[uint8]
    color: ptr UncheckedArray[uint8]

  let vertexArrays = cast[ptr UncheckedArray[IQMVertexArray]](cast[pointer](cast[int](header) + header.ofsVertexArrays.int))
  for i in 0 ..< header.numVertexArrays:
    let va = vertexArrays[i]
    
    case va.kind
    of vakPosition:
      position = cast[ptr UncheckedArray[float32]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].position, addr position[x * va.size], va.size * uint32(sizeof(float32)))
    of vakTexcoord:
      uv = cast[ptr UncheckedArray[float32]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].uv, addr uv[x * va.size], va.size * uint32(sizeof(float32)))
    of vakNormal:
      normal = cast[ptr UncheckedArray[float32]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].normal, addr normal[x * va.size], va.size * uint32(sizeof(float32)))
    of vakTangent:
      tangent = cast[ptr UncheckedArray[float32]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].tangent, addr tangent[x * va.size], va.size * uint32(sizeof(float32)))
    of vakBlendIndices:
      blendIndices = cast[ptr UncheckedArray[uint8]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].blendIndices, addr blendIndices[x * va.size], va.size * uint32(sizeof(uint8)))
    of vakBlendWeights:
      blendWeights = cast[ptr UncheckedArray[uint8]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].blendWeights, addr blendWeights[x * va.size], va.size * uint32(sizeof(uint8)))
    of vakColor:
      color = cast[ptr UncheckedArray[uint8]](cast[pointer](cast[int](header) + va.offset.int))
      for x in 0 ..< header.numVertices:
        copyMem(addr vertices[x].color, addr color[x * va.size], va.size * uint32(sizeof(uint8)))
    else:
      discard

  var
    bones: seq[Bone]
    joints = cast[ptr UncheckedArray[IQMJoint]](cast[pointer](cast[int](header) + header.ofsJoints.int))
  if header.ofsJoints > 0'u32:
    bones = newSeq[Bone](header.numJoints)
    for i in 0 ..< header.numJoints:
      var j = addr joints[i]
      echo cast[cstring](cast[uint32](data.mem) + header.ofsText.uint32 + fileText[j.name].uint32)

  data.close()