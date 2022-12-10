import std/strutils
import std/strformat
import std/sequtils
import std/algorithm
import std/sugar

type
  Tree = tuple
    height: int
    found: bool

proc scanTree(tree: Tree, answer: var int, maxHeight: var int): Tree =
  result = tree
  if tree.height > maxHeight:
    maxHeight = tree.height
    if not tree.found:
      answer += 1
      result = (tree.height, true)

proc calculate(row: var seq[Tree], reved = false): int =
  var
    answer = 0
    maxHeight = -1
    newRow: seq[Tree]

  if reved:
    newRow = row.reversed()
  else:
    newRow = row

  for i, r in newRow:
    newRow[i] = scanTree(r, answer, maxHeight)
  row = newRow

  return answer

func part1(content: seq[string]): int =
  var grid = map(
    content,
    (row) => zip(map(row, (c) => ord(c) - ord('0')), newSeq[bool](row.len()))
  )
  var answer = 0

  for row in grid.mitems():
    answer += calculate(row)
    answer += calculate(row, true)

  for i in 0 ..< grid.len():
    var col = map(grid, (row) => row[i])
    answer += calculate(col)
    answer += calculate(col, true)

  return answer

func checkVisibility(line: seq[int], height: int): int =
  result = 0
  for h in line:
    result += 1
    if h >= height:
      return result

  return result

proc part2(content: seq[string]): int =
  let grid = map(content, (row) => map(row, (c) => ord(c) - ord('0')))
  result = 0

  for i, row in grid:
    for j, h in row:
      var col = map(grid, (row) => row[j])
      var count = 
        checkVisibility(row[j+1 .. ^1], h) *
        checkVisibility(row[0 .. j-1].reversed(), h) *
        checkVisibility(col[i+1 .. ^1], h) *
        checkVisibility(col[0 .. i-1].reversed(), h)
      
      # echo fmt"{i}, {j} = {count}"
      result = max(result, count)

  return result
  
let content = readFile("./input.txt").strip().splitLines()

echo part1(content)
echo part2(content)
