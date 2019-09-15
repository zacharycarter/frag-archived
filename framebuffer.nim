import shader, window,
       bgfxdotnim, sdl2 as sdl

type
  Framebuffer* = ref object
    fbTextureHandles: array[2, bgfx_texture_handle_t]
    fbh: bgfx_frame_buffer_handle_t
    width, height: int

var
  layout: bgfx_vertex_layout_t
  vbh: bgfx_vertex_buffer_handle_t
  fboProgramHandle: bgfx_program_handle_t

proc init*() =
  fboProgramHandle = shader.loadProgram("vs_fbo", "fs_fbo")

  var vertices = [
    # pos                # uv
    -1.0'f32,  1.0'f32,  0.0'f32, 1.0'f32,
    -1.0'f32, -1.0'f32,  0.0'f32, 0.0'f32,
     1.0'f32, -1.0'f32,  1.0'f32, 0.0'f32,
    -1.0'f32,  1.0'f32,  0.0'f32, 1.0'f32,
     1.0'f32, -1.0'f32,  1.0'f32, 0.0'f32,
     1.0'f32,  1.0'f32,  1.0'f32, 1.0'f32
  ]

  bgfx_vertex_layout_begin(addr layout, BGFX_RENDERER_TYPE_NOOP)
  bgfx_vertex_layout_add(addr layout, BGFX_ATTRIB_POSITION, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_add(addr layout, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
  bgfx_vertex_layout_end(addr layout)

  vbh = bgfx_create_vertex_buffer(bgfx_make_ref(addr vertices[0], uint32(sizeof(vertices))), addr layout, BGFX_BUFFER_NONE)

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

  result.fbTextureHandles[0] = bgfx_create_texture_2d(
    uint16(result.width),
    uint16(result.height),
    false, 
    1,
    BGFX_TEXTURE_FORMAT_RGBA8, 
    BGFX_SAMPLER_MIN_POINT or BGFX_SAMPLER_MAG_POINT or BGFX_SAMPLER_U_BORDER or BGFX_SAMPLER_V_BORDER or BGFX_SAMPLER_W_BORDER or BGFX_SAMPLER_BORDER_COLOR(0),
    nil
  )

  result.fbTextureHandles[1] = bgfx_create_texture_2d(
    uint16(result.width),
    uint16(result.height),
    false,
    1,
    BGFX_TEXTURE_FORMAT_D24S8,
    BGFX_TEXTURE_RT_WRITE_ONLY,
    nil
  )

  result.fbh = bgfx_create_frame_buffer_from_handles(2, addr result.fbTextureHandles[0], true)

proc `bind`*(fb: Framebuffer) =
  bgfx_set_view_rect(0, 0, 0, uint16(fb.width), uint16(fb.height))
  bgfx_set_view_clear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x000000ff, 1.0, 0)
  bgfx_set_state(BGFX_STATE_DEPTH_TEST_LESS or BGFX_STATE_CULL_CCW, 0)
  


proc destroy*() =
  discard