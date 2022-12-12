import strutils
import sequtils
import sugar
import sets

type
  Position = tuple
    row: int
    col: int

  Input = tuple
    grid: seq[seq[int]]
    S: Position
    E: Position

proc parseFile(content: seq[string]): Input =
  var content = content
  for r, row in content:
    for c, e in row:
      case e:
        of 'S':
          result.S = (r, c)
          content[r][c] = chr(ord('a') - 1)
        of 'E':
          result.E = (r, c)
          content[r][c] = chr(ord('z') + 1)
        else:
          discard

  result.grid = map(
    content,
    (line) => map(
      line,
      (ch) => ord(ch) - ord('a')
    )
  )

let dpos = [[0, 1], [1, 0], [0, -1], [-1, 0]]
var part1 = true
proc bfs(input: Input): int =
  var q: seq[(Position, int)]
  var visited: HashSet[Position]
  if part1:
    q = @[(input.S, 0)]
    visited = toHashSet(@[input.S])
  else:
    q = @[(input.E, 0)]
    visited = toHashSet(@[input.E])

  let H = input.grid.len()
  let W = input.grid[0].len()

  while q.len() > 0:
    let cur = q[0][0]
    let pathLen = q[0][1]
    let curH = input.grid[cur.row][cur.col]
    q.delete(0)

    if part1:
      if cur == input.E:
        return pathLen
    else:
      if curH == 0:
        return pathLen

    for d in dpos:
      let next = Position((cur.row + d[0], cur.col + d[1]))
      if next.row < 0 or next.row >= H or next.col < 0 or next.col >= W:
        continue
      let nextH = input.grid[next.row][next.col]
      let gap = if part1: (nextH - curH) else: (curH - nextH)
      if gap <= 1 and next notin visited:
        q.add((next, pathLen+1))
        visited.incl(next)

let content = readFile("./input.txt").strip().splitLines()
let input = parseFile(content)
echo bfs(input)
part1 = false
echo bfs(input)
