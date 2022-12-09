import std/strutils

type
  Command = string
  # using LeFile for name because File already exists
  LeFile = ref object
    Size: int
    Name: string

type
  Directory = ref object
    Name: string
    Files: seq[LeFile]
    Parent: Directory
    Subdirectories: seq[Directory]

# Directory methods
method cd(self: Directory, path: string): Directory =
  if path == "..":
    return self.Parent

  for subdir in self.Subdirectories:
    if subdir.Name == path:
      return subdir

method add(self: Directory, file: LeFile): void =
  self.Files.add(file)

method add(self: Directory, dir: Directory): void =
  self.Subdirectories.add(dir)

let total = 70_000_000 
var part1 = 0
var minRemoved = total

method size(self: Directory, freeThreshold = total): int =
  var size = 0
  for file in self.Files:
    size += file.Size

  for subdir in self.Subdirectories:
    size += subdir.size(freeThreshold)

  if size <= 100_000:
    part1 += size

  if size >= freeThreshold:
    minRemoved = min(minRemoved, size)

  return size

proc run(root: Directory, input: seq[Command]): void = 
  # start pc from 1 to ignore "cd /" command thats coming first
  var pc = 1
  var current = root

  let endpc = input.len()
  while pc < endpc:
    let command = input[pc]
    assert(command[0] == '$')
    
    let tokens = command.splitWhitespace()

    case tokens[1]:
      of "cd":
        current = current.cd(tokens[2])
        pc += 1
      of "ls":
        pc += 1
        while pc < endpc:
          let file = input[pc]
          # end of file list
          if file[0] == '$':
            break
          
          let fileInfo = file.splitWhitespace()
          if fileInfo[0] == "dir":
            current.add(Directory(Name: fileInfo[1], Files: @[], Parent: current, Subdirectories: @[]))
          else:
            current.add(LeFile(Size: fileInfo[0].parseInt(), Name: fileInfo[1]))
          pc += 1
      else:
        assert(false)

  return

let content = readFile("./input.txt").strip().splitLines()

var root = Directory(Name: "/", Files: @[], Parent: nil, Subdirectories: @[])
run(root, content)

let totalUsed = root.size()
let totalFree = total - totalUsed
discard root.size(30_000_000 - totalFree)

echo part1
echo minRemoved
