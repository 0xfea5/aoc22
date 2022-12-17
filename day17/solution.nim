import strutils
import sets
import strformat
import tables

type
  Point = tuple
    x: int64
    y: int64

  Block = seq[Point]

let blocks = [
  # @@@@
  @[(-1i64,0i64),(0i64,0i64),(1i64,0i64),(2i64,0i64)],
  # .@.
  # @@@
  # .@.
  @[(-1i64,1i64),(0i64,0i64),(0i64,1i64),(0i64,2i64),(1i64,1i64)],
  # ..@
  # ..@
  # @@@
  @[(-1i64,0i64),(0i64,0i64),(1i64,0i64),(1i64,1i64),(1i64,2i64)],
  # @
  # @
  # @
  # @
  @[(-1i64,0i64),(-1i64,1i64),(-1i64,2i64),(-1i64,3i64)],
  # @@
  # @@
  @[(-1i64,0i64),(0i64,0i64),(-1i64,1i64),(0i64,1i64)]
]

let
  minX = -3i64
  maxX = 3i64

proc outOfBorders(a: Point): bool =
  a.x < minX or a.x > maxX

proc `+`(a, b: Point): Point =
  result = (a.x + b.x, a.y + b.y)

proc peak(b: Block): int64 =
  for s in b:
    result = max(result, s.y)

proc collides(b: Block, occupied: HashSet[Point]): bool =
  for s in b:
    if occupied.contains(s):
      return true
  return false
    
proc move(b: Block, offset: Point, occupied: HashSet[Point]): Block =
  for s in b:
    let toPush = s + offset
    if toPush.outOfBorders():
      return b
    result.add(toPush)

  if result.collides(occupied):
    return b

proc drop(input: string, index: var int64, peak: int64, b: Block, occupied: var HashSet[Point]): int64 =
  var
    curr = b.move((0i64 ,peak+4), occupied)

  while true:
    if index < input.len():
      case input[index]:
        of '<':
          curr = curr.move((-1i64, 0i64), occupied)
        of '>':
          curr = curr.move((1i64, 0i64), occupied)
        else:
          assert(false)
      index = (index + 1) mod input.len()
    let next = curr.move((0i64, -1i64), occupied)
    # Collision happened
    if curr == next:
      break
    curr = next
  
  # Blocked collided
  for s in curr:
    occupied.incl(s)

  max(curr.peak(), peak)

proc draw(occupied: HashSet[Point], peak: int64): void =
  for y in countdown(peak, 0i64, 1i64):
    var line = ""
    for x in minX .. maxX:
      line &= (if occupied.contains((x,y)): '#' else: ' ')
    echo '|' & line & '|'

proc solve(input: string, cap: int64): int64 =
  var
    reduced = false
    dp: Table[(int64, int64), (int64, int64, int64)]
    occupied = toHashSet([(-3i64,0i64), (-2i64,0i64), (-1i64,0i64), (0i64,0i64), (3i64,0i64), (2i64,0i64), (1i64,0i64)])
    index = 0i64
    i = 0i64
    peak = 0i64
  while i < cap:
    let currState = (i mod 5, index)
    # echo fmt"currState = {currState} -> {(peak, i)}"
    block InitState:
      if not reduced and dp.hasKeyOrPut(currState, (peak, i, 0i64)):
        let
          (oldResult, oldI, oldIncrease) = dp[currState]
          period = i - oldI
          increase = peak - oldResult
          distToCap = cap - i
          repeats = distToCap div period
          rest = distToCap mod period

        # Initialise increments
        if oldIncrease != increase:
          dp[currState] = (peak, i, increase)
          break InitState

        assert(oldIncrease == increase)
        echo fmt"currState = {currState}"
        echo fmt"period = {period}, increase = {increase}, repeats = {repeats}"
        result += repeats * increase
        i = cap - rest
        reduced = true
        continue

    # echo fmt"i = {i}"
    let newPeak = drop(input, index, peak, blocks[i mod 5], occupied)
    result += newPeak - peak
    peak = newPeak
    i += 1
    # echo peak
  # occupied.draw(peak)

let content = readFile("./input.txt").strip()

echo solve(content, 2022i64)
# run solve with large enough cap to find replayPoint
echo solve(content, 1_000_000_000_000)
