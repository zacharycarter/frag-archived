import parsecfg, streams, strutils, tables

type
  ConfigEntryKind* = enum
    cekInt
    cekString
    cekCount

  ConfigEntry* = object
    case kind*: ConfigEntryKind
    of cekInt:
      i*: int
    of cekString:
      s*: string
    of cekCount:
      discard

  Config* = object
    entries*: Table[string, ConfigEntry]
    success: bool

proc isInt(v: string): bool =
  try:
    discard parseInt(v)
  except ValueError:
    return false
  
  result = true

proc loadConfig*(path: string): Config =
  var f = newFileStream(path, fmRead)
  if f != nil:
    var p: CfgParser
    open(p, f, path)
    while true:
      var e = next(p)
      case e.kind
      of cfgEof: break
      of cfgSectionStart:   ## a ``[section]`` has been parsed
        continue
      of cfgKeyValuePair:
        var entry: ConfigEntry
        if isInt(e.value):
          entry = ConfigEntry(kind: cekInt, i: parseInt(e.value))
        else:
          entry = ConfigEntry(kind: cekString, s: e.value)
        result.entries.add(e.key, entry)
      of cfgOption:
        continue
      of cfgError:
        continue
    close(p)
  else:
    echo("cannot open: " & path)
    result.success = false
  
  result.success = true
  echo result