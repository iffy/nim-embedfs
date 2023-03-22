# embedfs

Embed directories of files in your executable. It's like `staticRead`/`slurp` for whole directories.


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

