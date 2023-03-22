import std/algorithm
import std/os
import std/sequtils
import std/unittest
import embedfs

let TESTDIR = currentSourcePath.parentDir()

test "listDir":  
  const fs = embedDir("data")
  let list = fs.listDir().toSeq().sorted()
  check list == @["bar.txt", "foo.txt", "image.png"]

  let list2 = fs.listDir("subdir").toSeq().sorted()
  check list2 == @["apple.txt", "banana.txt"]

test "walk":
  const fs = embedDir("data")
  let list = fs.walk().toSeq().sorted()
  check list == @["bar.txt", "foo.txt", "image.png",
    "subdir"/"apple.txt", "subdir"/"banana.txt"]

test "get":
  const fs = embedDir("data")
  check fs.get("bar.txt") == some("bar\l")

test "dynamic":
  const fs = embedDir("_dynamic", embed = false)
  let dyndir = TESTDIR/"_dynamic"
  removeDir(dyndir)
  createDir(dyndir)
  check fs.listDir().toSeq().len == 0
  check fs.walk().toSeq().len == 0
  check fs.get("foo.txt").isNone

  writeFile(dyndir/"foo.txt", "foo")
  writeFile(dyndir/"bar.txt", "bar")
  createDir(dyndir/"sub")
  writeFile(dyndir/"sub"/"hey.txt", "hey")

  check fs.listDir().toSeq().sorted() == @["bar.txt", "foo.txt"]
  check fs.listDir("sub").toSeq().sorted() == @["hey.txt"]
  check fs.walk().toSeq().sorted() == @["bar.txt", "foo.txt", "sub"/"hey.txt"]
  check fs.get("foo.txt") == some("foo")

  writeFile(dyndir/"foo.txt", "foo2")
  check fs.get("foo.txt") == some("foo2")

test "dynamic path":
  const fs = embedDir("data", embed = false)
  writeFile(TESTDIR/"data"/"dyn.txt", "dyn")
  defer: removeFile(TESTDIR/"data"/"dyn.txt")
  check fs.get("dyn.txt") == some("dyn")
