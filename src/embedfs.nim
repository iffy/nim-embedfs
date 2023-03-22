## If you want to refactor this implementation to make it
## better (more efficient/faster/compression), just make sure the tests pass.
import std/os
import std/strutils
import std/tables
import std/options; export options

type
  EmbeddedTable* = Table[string, string]
  EmbeddedFS* = distinct EmbeddedTable
    ## This distinct type is to prevent users from depending
    ## on the implementation being a Table
  
  RuntimeEmbeddedFS* = distinct string

template VLOG(msg: string) =
  when defined(embedfsVerbose):
    echo "[embedfs] ", msg
  else:
    discard

template embedDir*(dirname: string, embed:static[bool] = true): untyped =
  ## Embed a directory of files into this program.
  ## 
  ## `dirname` = directory to embed
  ## 
  ## `embed` = if true (default), embed files into the program.
  ## If `false`, files are read from disk at runtime. This is useful when
  ## testing (so you don't have to recompile the program to test changes
  ## in embedded assets).
  when embed:
    const tmp = static:
      var files = initTable[string, string](0)
      let rootdir = instantiationInfo(-1, true).filename.parentDir
      let fulldir = rootdir / dirname
      VLOG "embedding dir " & fulldir
      for relpath in walkDirRec(rootdir / dirname, relative = true):
        files[relpath] = staticRead(fulldir / relpath)
        VLOG " + " & relpath & " size=" & $files[relpath].len
      files
    tmp.EmbeddedFS
  else:
    let rootdir = instantiationInfo(-1, true).filename.parentDir
    (rootdir / dirname).RuntimeEmbeddedFS

iterator listDir*(ed: EmbeddedFS|RuntimeEmbeddedFS, subdir = ""): string =
  ## List all embedded file names within the given directory
  when ed is EmbeddedFS:
    for key in ed.EmbeddedTable.keys:
      if subdir == "":
        if DirSep notin key:
          yield key
      else:
        if key.startsWith(subdir & DirSep):
          yield key.substr(len(subdir)+1)
  else:
    # runtime "embed"
    let fulldir = ed.string / subdir
    for item in walkDir(fulldir):
      if item.kind == pcFile:
        yield item.path.relativePath(fulldir)

iterator walk*(ed: EmbeddedFS|RuntimeEmbeddedFS): string =
  ## List all embedded file names
  when ed is EmbeddedFS:
    for key in ed.EmbeddedTable.keys:
      yield key
  else:
    # runtime "embed"
    for path in walkDirRec(ed.string, relative=true):
      yield path

proc get*(ed: EmbeddedFS|RuntimeEmbeddedFS, filename: string): Option[string] =
  ## Get a previously-embedded file's contents
  when ed is EmbeddedFS:
    if ed.EmbeddedTable.hasKey(filename):
      return some(ed.EmbeddedTable[filename])
  else:
    # runtime "embed"
    try:
      return some(readFile(ed.string / filename))
    except:
      discard
