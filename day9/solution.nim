import strutils
import sequtils
import sets

type Move = tuple[Direction: char, Distance: int]
type Position = tuple[r: int, c: int]

proc parse(content: seq[string]): seq[Move] =
  let moves = map(content, 
                  proc (line: string): Move =
                    let temp = line.split(" ")
                    (temp[0][0], temp[1].parseInt())
              )
  return moves

proc move(rope: var seq[Position], uniqPositions: var HashSet[Position]): void =
  for i in 1 ..< rope.len():
    # rope[i-1] = leader
    # rope[i] = follower
    let roffset = rope[i-1].r - rope[i].r
    let coffset = rope[i-1].c - rope[i].c

    if roffset in [2, -2]:
      rope[i].r += int(roffset/2)
      if coffset in [-1, 1]:
        rope[i].c = rope[i-1].c

    if coffset in [2, -2]:
      rope[i].c += int(coffset/2)
      if roffset in [-1, 1]:
        rope[i].r = rope[i-1].r

  uniqPositions.incl(rope[rope.len()-1])

proc emulate(moves: seq[Move], len = 2): int =
  var rope = newSeq[Position](len)
  var uniqPositions: HashSet[Position]
  init(uniqPositions)
  echo rope
  for move in moves:
    for i in 1 .. move.Distance:
      case move.Direction:
        of 'U':
          rope[0].r -= 1
        of 'R':
          rope[0].c += 1
        of 'D':
          rope[0].r += 1
        of 'L':
          rope[0].c -= 1
        else:
          assert(false)
      move(rope, uniqPositions)

  return len(uniqPositions)

let content = readFile("./input.txt").strip().splitLines()
let moves = parse(content)

echo emulate(moves)
echo emulate(moves, 10)
