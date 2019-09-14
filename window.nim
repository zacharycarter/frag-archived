import strformat,
       bgfxdotnim, bgfxdotnim/platform, sdl2 as sdl

type
  Window = object
    windowPtr*: sdl.WindowPtr
    width: int
    height: int

const
  sdlMajorVersion* = 2
  sdlMinorVersion* = 0
  sdlPatchLevel* = 10
  defaultFlags = SDL_WINDOW_SHOWN or SDL_WINDOW_RESIZABLE

template sdlVersion*(x: untyped) =
  (x).major = sdlMajorVersion
  (x).minor = sdlMinorVersion
  (x).patch = sdlPatchLevel

when defined(windows):
  type
    SysWMMsgWinObj* = object
      window*: pointer

    SysWMInfoKindObj* = object
      win*: SysWMMsgWinObj

var display*: Window

proc linkSDL2BGFX(): bool =
  var pd: bgfx_platform_data_t
  var info: sdl.WMinfo
  sdlVersion(info.version)
  if not sdl.getWMInfo(display.windowPtr, info):
    return result
  
  case(info.subsystem):
    of SysWM_Windows:
      when defined(windows):
        let info = cast[ptr SysWMInfoKindObj](addr info.padding[0])
        pd.nwh = cast[pointer](info.win.window)
      pd.ndt = nil
    else:
      discard

  pd.backBuffer = nil
  pd.backBufferDS = nil
  pd.context = nil
  bgfx_set_platform_data(addr pd)
  result = true

proc init*(width, height: int; title: string): bool =
  if sdl.init(INIT_VIDEO) != SdlSuccess:
    echo &"Failed to initialize SDL:\n {sdl.getError()}"
    return result
  
  display.windowPtr = sdl.createWindow(
    title,
    SDL_WINDOWPOS_CENTERED,
    SDL_WINDOWPOS_CENTERED,
    cint(width),
    cint(height),
    defaultFlags
  )

  if display.windowPtr.isNil:
    echo &"Failed to create SDL window:\n {sdl.getError()}"
    return result

  if not linkSDL2BGFX():
    echo &"Failed to retrieve driver specific info from SDL window:\n {sdl.getError()}"
    return result

  var bgfxInit: bgfx_init_t
  bgfx_init_ctor(addr bgfxInit)
  if not bgfx_init(addr bgfxInit):
    echo "Failed initializing BGFX"
    return result

  display.width = width
  display.height = height

  result = true

proc destroy*() =
  bgfx_shutdown()
  display.windowPtr.destroyWindow()