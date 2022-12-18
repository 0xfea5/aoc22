import strutils
import sequtils
import sugar
import sets

type Cube = tuple
  x, y, z: int

proc parseLine(line: string): Cube =
  let tokens = map(line.split(","), (e) => e.parseInt())
  (tokens[0], tokens[1], tokens[2])

proc parseFile(content: string): seq[Cube] =
  let lines = content.strip().splitLines()
  result = map(lines, parseLine)

proc nextTo(A, B: Cube): bool =
  let
    dx = abs(A.x - B.x)
    dy = abs(A.y - B.y)
    dz = abs(A.z - B.z)

  dx + dy + dz <= 1 and dx <= 1 and dy <= 1 and dz <= 1

proc part1(cubes: seq[Cube]): int =
  result = 6 * cubes.len()
  for i, cube in cubes[0 .. ^2]:
    for other in cubes[i+1 .. ^1]:
      if cube.nextTo(other):
        result -= 2

var
  solid: HashSet[Cube]
  visited: HashSet[Cube]
  maxn = 0
  minn = -1

proc blocksAround(cube: Cube): int =
  for x in [cube.x-1, cube.x+1]:
    if (x, cube.y, cube.z) in solid:
      result += 1

  for y in [cube.y-1, cube.y+1]:
    if (cube.x, y, cube.z) in solid:
      result += 1

  for z in [cube.z-1, cube.z+1]:
    if (cube.x, cube.y, z) in solid:
      result += 1

proc dfs(curr: Cube): int =
  let maxp = max([curr.x, curr.y, curr.z])
  let minp = min([curr.x, curr.y, curr.z])
  if minp < minn or maxp >= maxn or visited.containsOrIncl(curr):
    return 0

  # if is air block
  if curr notin solid:
    result = blocksAround(curr) +
      dfs((curr.x+1, curr.y, curr.z)) +
      dfs((curr.x-1, curr.y, curr.z)) +
      dfs((curr.x, curr.y+1, curr.z)) +
      dfs((curr.x, curr.y-1, curr.z)) +
      dfs((curr.x, curr.y, curr.z+1)) +
      dfs((curr.x, curr.y, curr.z-1))


proc part2(cubes: seq[Cube]): int =
  # echo cubes
  for cube in cubes:
    maxn = max([cube.x, cube.y, cube.z])
  maxn += 6

  for cube in cubes:
    solid.incl(cube)

  result = dfs((0,0,0))

let content = readFile("./input.txt")
let input = parseFile(content)

echo part1(input)
echo part2(input)
