import strutils
import sequtils
import re
import sugar
import algorithm
import sets

type
  Point = tuple
    x: int
    y: int
  
  Range = tuple
    b: int
    l: int

  Entry = tuple
    sensor: Point
    beacon: Point
    distance: int

proc distance(A, B: Point): int =
  result = abs(A.x - B.x) + abs(A.y - B.y)

proc disjoinWith(A, B: Range): bool =
  return A.b + A.l < B.b

proc rangeContains(r: Range, y: int, p: Point): bool =
  p.y == y and r.b <= p.x and p.x <= r.b + r.l - 1

proc unite(A, B: Range): Range =
  assert(A.b <= B.b)
  assert(not A.disjoinWith(B))
  result = (A.b, max(A.l, B.b - A.b + B.l))

proc rangeComparator(A, B: Range): int =
  if A.b < B.b or (A.b == B.b and A.l <= B.l):
    return -1
  else:
    return 1

proc parsePoint(strPoint: string): Point = 
  let tokens = strPoint.split(",")
  Point((tokens[0].parseInt(), tokens[1].parseInt()))

proc parseEntry(strEntry: string): Entry =
  let tokens = strEntry.split(":")
  let points = @[tokens[0].parsePoint(), tokens[1].parsePoint()]
  Entry((points[0], points[1], distance(points[0], points[1])))

proc parseFile(content: string): seq[Entry] =
  let lines = content.strip().splitLines()

  let strEntries = map(
    lines,
    (line) => line.replace(re"[^0-9\-,:]")
  )

  result = map(
    strEntries,
    parseEntry
  )

proc emptyRanges(entries: seq[Entry], criticalLine: int): seq[Range] =
  var emptyRanges: seq[Range]
  for entry in entries:
    let
      distFromLine = abs(entry.sensor.y - criticalLine)
      rangeFromMid = entry.distance - distFromLine
      b = entry.sensor.x - rangeFromMid
      e = entry.sensor.x + rangeFromMid
      l = e - b + 1
    if l > 0:
      emptyRanges.add((b, l))

  emptyRanges.sort(rangeComparator)
  var
    curr = emptyRanges[0]
    lastPushed = true

  for other in emptyRanges[1..^1]:
    lastPushed = false
    if curr.disjoinWith(other):
      result.add(curr)
      lastPushed = true
      curr = other
    else:
      curr = curr.unite(other)

  if not lastPushed:
    result.add(curr)

proc part1(entries: seq[Entry], criticalLine = 2_000_000): int =
  # List of all beacons
  var beacons: HashSet[Point]
  for entry in entries:
    beacons.incl(entry.beacon)

  let empty = emptyRanges(entries, criticalLine)
  for r in empty:
    result += r.l
    for b in beacons:
      if r.rangeContains(criticalLine, b):
        result -= 1

proc part2(entries: seq[Entry], criticalLength = 4_000_000): int =
  for y in 0 .. criticalLength:
    let empty = emptyRanges(entries, y)
    if empty.len() == 2:
      let x = empty[0].b + empty[0].l
      return x * 4_000_000 + y

let content = readFile("./input.txt")
let entries = parseFile(content)

echo part1(entries)
echo part2(entries)
