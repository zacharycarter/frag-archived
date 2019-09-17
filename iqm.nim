import memfiles, strutils,
       cache, mesh, model, scene

type
  IQMLoadingFlag* = enum
    ilKeepVertices
  
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
    kind: uint32
    flags: uint32
    format: uint32
    size: uint32
    offset: uint32

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
  
  let 
    meshes = cast[ptr UncheckedArray[IQMMesh]](cast[pointer](cast[int](header) + header.ofsMeshes.int))
    fileText = if header.ofsText > 0'u32: cast[cstring](cast[pointer](cast[int](header) + header.ofsText.int)) else: ""

  var vertices = newSeq[Vertex](header.numVertices)
  let vertexArrays = cast[ptr UncheckedArray[IQMVertexArray]](cast[pointer](cast[int](header) + header.ofsVertexArrays.int))
  for i in 0 ..< header.numVertexArrays:
    let va = vertexArrays[i]
    echo va.kind
  
  data.close()