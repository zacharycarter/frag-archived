import tables,
       model, texture

var
  textureCache: Table[string, Texture]
  modelCache: Table[string, Model]