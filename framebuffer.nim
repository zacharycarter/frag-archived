import window,
       bgfxdotnim, sdl2 as sdl

type
  Framebuffer* = ref object
    fbTextureHandles: array[2, bgfx_texture_handle_t]
    fbh: bgfx_frame_buffer_handle_t
    width, height: int

proc init*() =
  discard
    
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

proc destroy*() =
  discard