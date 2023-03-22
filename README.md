# embedfs

Embed directories of files in your executable. It's like `staticRead`/`slurp` for whole directories.

[![.github/workflows/tests.yml](https://github.com/iffy/nim-embedfs/actions/workflows/tests.yml/badge.svg)](https://github.com/iffy/nim-embedfs/actions/workflows/tests.yml)

## Installation

```
nimble install https://github.com/iffy/nim-embedfs
```

## Usage

```nim
import embedfs
const data = embedDir("data")
echo data.get("somefile.txt").get()
doAssert data.get("nonexisting.txt").isNone

for filename in data.listDir():
  echo filename

for filename in data.walk():
  echo filename
```

You can also change from embedding at compile-time (the default) to reading files from disk at runtime for testing purposes with `embed = false`, because sometimes it's nice to not have to recompile the whole program just to get new assets:

```nim
import embedfs
const data = embedDir("data", embed = false)
writeFile("data"/"foo.txt", "foo")
doAssert data.get("foo.txt") == some("foo")
writeFile("data"/"foo.txt", "new value")
doAssert data.get("foo.txt") == some("new value")
```