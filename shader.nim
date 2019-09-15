import os,
      bgfxdotnim, sdl2 as sdl

proc loadShader(name: string): bgfx_shader_handle_t =
  var
    filePath: string 
    shaderPath = "???"

  case bgfx_get_renderer_type()
  of BGFX_RENDERER_TYPE_DIRECT3D11, BGFX_RENDERER_TYPE_DIRECT3D12:
    shaderPath = "shaders/dx11/"
  else:
    assert(false)
  
  filePath = shaderPath & name & ".bin"

  let stream = sdl.rwFromFile(filePath, "r")
  if stream == nil:
    return BGFX_INVALID_HANDLE
  
  let size = size(stream)
  var ret = alloc(size + 1)
  if ret == nil:
    discard close(stream)
    return BGFX_INVALID_HANDLE
  
  var o = ret
  var read, readTotal = 0'i64
  while readTotal < size:
    read = read(stream, o, csize(1), csize(size - readTotal))

    if read == 0:
      break
    
    readTotal += read
    o = cast[pointer](cast[int64](o) + read)
  
  discard close(stream)
  
  if readTotal != size:
    return BGFX_INVALID_HANDLE
  
  zeroMem(o, 1)
  result = bgfx_create_shader(bgfx_make_ref(ret, uint32(size)))
  bgfx_set_shader_name(result, name, int32(len(name)))
  dealloc(ret)

proc loadProgram*(vsName:string; fsName: string = ""): bgfx_program_handle_t =
  var 
    vsh = loadShader(vsName)
    fsh = BGFX_INVALID_HANDLE
  
  if len(fsName) > 0:
    fsh = loadShader(fsName)
  
  result = bgfx_create_program(vsh, fsh, true)