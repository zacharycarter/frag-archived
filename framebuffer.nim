import shader, window,
       bgfxdotnim, sdl2 as sdl

type
  Framebuffer* = ref object
    textureHandles: array[2, bgfx_texture_handle_t]
    handle: bgfx_frame_buffer_handle_t
    width, height: int
  
  PosColorTexCoord0Vertex = object
    x, y, z: float32
    rgba: uint32
    u, v: float32

var
  layout: bgfx_vertex_layout_t
  fboProgramHandle: bgfx_program_handle_t

proc screenSpaceQuad(textureWidth, textureHeight: float32; originBottomLeft = false; width, height = 1.0'f32) =
  if 3'u32 == bgfx_get_avail_transient_vertex_buffer(3'u32, addr layout):
    var vb: bgfx_transient_vertex_buffer_t
    bgfx_alloc_transient_vertex_buffer(addr vb, 3'u32, addr layout)
    var vertex = cast[ptr UncheckedArray[PosColorTexCoord0Vertex]](vb.data)

    let 
      zz = 0.0'f32

      minX = -width
      maxX = width
      minY = 0.0'f32
      maxY = height * 2.0'f32

      texelHalfW = 0.0'f32 / textureWidth
      texelHalfH = 0.0'f32 / textureHeight
      minU = -1.0'f32 + texelHalfW
      maxU = 1.0'f32 + texelHalfW
    
    var 
      minV = texelHalfH
      maxV = 2.0'f32 + texelHalfH
    
    if originBottomLeft:
      var temp = minV
      minV = maxV
      maxV = temp

      minV -= 1.0'f32
      maxV -= 1.0'f32
    
    vertex[0].x = minx
    vertex[0].y = miny
    vertex[0].z = zz
    vertex[0].rgba = 0xffffffff'u32
    vertex[0].u = minu
    vertex[0].v = minv

    vertex[1].x = maxx
    vertex[1].y = miny
    vertex[1].z = zz
    vertex[1].rgba = 0xffffffff'u32
    vertex[1].u = maxu
    vertex[1].v = minv

    vertex[2].x = maxx
    vertex[2].y = maxy
    vertex[2].z = zz
    vertex[2].rgba = 0xffffffff'u32
    vertex[2].u = maxu
    vertex[2].v = maxv
    
    bgfx_set_transient_vertex_buffer(0, addr vb, 0, high(uint32))

proc init*() =
  fboProgramHandle = shader.loadProgram("vs_fbo", "fs_fbo")

  bgfx_vertex_layout_begin(addr layout, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_layout_add(addr layout, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr layout, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false)
  bgfx_vertex_layout_add(addr layout, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_end(addr layout)

proc newFramebuffer*(width, height: int): Framebuffer =
  result = new Framebuffer
  result.width = width
  result.height = height

  var vw, vh: cint
  sdl.getSize(display.windowPtr, vw, vh)
  result.width = if width == 0: int(vw) else: width
  result.height = if height == 0: int(vh) else: height

  var border = [1.0'f32, 1.0, 1.0, 1.0]
  bgfx_set_palette_color(0, border)

  result.textureHandles[0] = bgfx_create_texture_2d(
    uint16(result.width),
    uint16(result.height),
    false, 
    1,
    BGFX_TEXTURE_FORMAT_RGBA8, 
    BGFX_SAMPLER_MIN_POINT or BGFX_SAMPLER_MAG_POINT or BGFX_SAMPLER_U_BORDER or BGFX_SAMPLER_V_BORDER or BGFX_SAMPLER_W_BORDER or BGFX_SAMPLER_BORDER_COLOR(0),
    nil
  )

  result.textureHandles[1] = bgfx_create_texture_2d(
    uint16(result.width),
    uint16(result.height),
    false,
    1,
    BGFX_TEXTURE_FORMAT_D24S8,
    BGFX_TEXTURE_RT_WRITE_ONLY,
    nil
  )

  result.handle = bgfx_create_frame_buffer_from_handles(2, addr result.textureHandles[0], true)

proc `bind`*(fb: Framebuffer) =
  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)
  bgfx_set_view_rect_auto(0, 0, 0, BGFX_BACKBUFFER_RATIO_EQUAL)
  bgfx_set_view_frame_buffer(0, fb.handle)

proc draw*(fb: Framebuffer; w, h: int) =
  bgfx_set_texture(0, uniform(fboProgramHandle, BGFX_UNIFORM_TYPE_SAMPLER, 1, "s_texColor"), fb.textureHandles[0], high(uint32))
  bgfx_set_state(BGFX_STATE_WRITE_RGB or BGFX_STATE_WRITE_A, 0)
  screenSpaceQuad(float32(w), float32(h))
  bgfx_submit(0, fboProgramHandle, 0, false)

proc destroy*() =
  discard