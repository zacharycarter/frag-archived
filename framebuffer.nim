import bgfxdotnim

type
  Framebuffer* = ref object
    fbTextureHandles: array[2, bgfx_texture_handle_t]
    fbh: bgfx_frame_buffer_handle_t

proc init*() =
  discard
    
proc newFramebuffer*(width, height: int): Framebuffer =
  result = new Framebuffer

  var border = [1.0'f32, 1.0, 1.0, 1.0]
  bgfx_set_palette_color(0, border)

  result.fbTextureHandles[0] = bgfx_create_texture_2d(
    uint16(width),
    uint16(height),
    false, 
    1,
    BGFX_TEXTURE_FORMAT_RGBA8, 
    BGFX_SAMPLER_MIN_POINT or BGFX_SAMPLER_MAG_POINT or BGFX_SAMPLER_U_BORDER or BGFX_SAMPLER_V_BORDER or BGFX_SAMPLER_W_BORDER or BGFX_SAMPLER_BORDER_COLOR(0),
    nil
  )

  result.fbTextureHandles[1] = bgfx_create_texture_2d(
    uint16(width),
    uint16(height),
    false,
    1,
    BGFX_TEXTURE_FORMAT_D24S8,
    BGFX_TEXTURE_RT_WRITE_ONLY,
    nil
  )

  result.fbh = bgfx_create_frame_buffer_from_handles(2, addr result.fbTextureHandles[0], true)



