import tables,
       model, texture

var
  textureCache: Table[string, Texture]
  modelCache: Table[string, Model]

proc getModel*(path: string): Model =
  if modelCache.contains(path):
    return modelCache[path]