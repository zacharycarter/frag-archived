import os,
       nimterop/[cimport, paths]

const
  baseDir = currentSourcePath.parentDir()/"lib"
  srcDir = baseDir/"physfs/src"

static:
  cDebug()
  cDisableCaching()

cIncludeDir(srcDir)
cCompile(srcDir/"physfs_archiver_7z.c")
cCompile(srcDir/"physfs_archiver_dir.c")
cCompile(srcDir/"physfs_archiver_grp.c")
cCompile(srcDir/"physfs_archiver_hog.c")
cCompile(srcDir/"physfs_archiver_iso9660.c")
cCompile(srcDir/"physfs_archiver_mvl.c")
cCompile(srcDir/"physfs_archiver_qpak.c")
cCompile(srcDir/"physfs_archiver_slb.c")
cCompile(srcDir/"physfs_archiver_unpacked.c")
cCompile(srcDir/"physfs_archiver_vdf.c")
cCompile(srcDir/"physfs_archiver_wad.c")
cCompile(srcDir/"physfs_archiver_zip.c")
cCompile(srcDir/"physfs_byteorder.c")
cCompile(srcDir/"physfs_unicode.c")
cCompile(srcDir/"physfs.c")

when defined windows:
  cCompile(srcDir/"physfs_platform_windows.c")

cPlugin:
  import strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    sym.name = sym.name.strip(chars = {'_'})
    sym.name = sym.name.replace("PHYSFS_stat", "PHYSFS_stats")

cImport(srcDir/"physfs.h", recurse = true)