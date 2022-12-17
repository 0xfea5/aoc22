import strutils
import sequtils
import sets
import strformat

type Point = tuple[row: int, col: int]

proc has(occupied: HashSet[Point], point: Point): bool =
  point in occupied

proc parsePoint(point: string): Point =
  let tokens = point.split(",")
  assert(tokens.len() == 2)
  Point((tokens[1].parseInt(), tokens[0].parseInt()))

proc parseLine(line: string): seq[Point] =
  map(line.replace("-> ").split(" "), parsePoint)

var maxRow = -1
var maxCol = -1
var minCol = 10000
proc parseFile(content: string): HashSet[Point] =
  let lines = content.strip.splitLines()
  var rockLists = map(lines, parseLine)

  for row in rockLists:
    for point in row:
      maxRow = max(maxRow, point.row)
      maxCol = max(maxCol, point.col)
      minCol = min(minCol, point.col)
  
  for rocks in rockLists:
    # a = begin, b = end
    for i, a in rocks[0..^2]:
      let b = rocks[i+1]
      # echo fmt"a = {a}, b = {b}"
      for col in min(a.col, b.col) .. max(a.col, b.col):
        let toPush = Point((a.row, col))
        result.incl(toPush)

      for row in min(a.row, b.row) .. max(a.row, b.row):
        let toPush = Point((row, a.col))
        result.incl(toPush)

proc draw(occupied: HashSet[Point]): void =
  for row in 0 .. maxRow:
    var line = ""
    for col in minCol .. maxCol:
      let current = Point((row, col))
      line &= (if occupied.has(current): '#' else: '.')

    echo line

proc below(point: Point): Point =
  Point((point.row+1, point.col))

proc rbelow(point: Point): Point =
  Point((point.row+1, point.col+1))

proc lbelow(point: Point): Point =
  Point((point.row+1, point.col-1))

proc outOfBounds(point: Point): bool =
  point.row > maxRow

var part2 = false
proc drop(occupied: var HashSet[Point], col: int): bool =
  var point = Point((0, col))
  
  if part2 and occupied.has(point):
    return false

  while true:
    let
      below = point.below()
      rbelow = point.rbelow()
      lbelow = point.lbelow()

    if point.outOfBounds():
      if part2:
        break
      return false

    if not occupied.has(below):
      point = below
      continue
    if not occupied.has(lbelow):
      point = lbelow
      continue

    if not occupied.has(rbelow):
      point = rbelow
      continue

    break
  occupied.incl(point)
  return true

proc solve(occupied: HashSet[Point]): int =
  var occupied = occupied
  while drop(occupied, 500):
    result += 1

let content = readFile("./input.txt")
let occupied = parseFile(content)

occupied.draw()
# echo fmt"{maxRow}, {minCol}-{maxCol}"
echo solve(occupied)
part2 = true
echo solve(occupied)
