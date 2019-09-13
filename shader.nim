import os,
      bgfxdotnim

proc loadShader(name: string): bgfx_shader_handle_t =
  var
    filePath: string 
    shaderPath = "???"

  case bgfx_get_renderer_type()
  of BGFX_RENDERER_TYPE_DIRECT3D11, BGFX_RENDERER_TYPE_DIRECT3D12:
    shaderPath = "shaders/dx11"
  else:
    assert(false)
  
  filePath = shaderPath & name & ".bin"

  var shaderSrc = readFile(filePath)
  result = bgfx_create_shader(bgfx_make_ref(addr shaderSrc, uint32(getFileSize(filePath))))
  bgfx_set_shader_name(result, name, int32(len(name)))

proc loadProgram*(vsName:string; fsName: string = ""): bgfx_program_handle_t =
  var 
    vsh = loadShader(vsName)
    fsh = BGFX_INVALID_HANDLE
  
  if len(fsName) > 0:
    fsh = loadShader(fsName)
  
  result = bgfx_create_program(vsh, fsh, true)