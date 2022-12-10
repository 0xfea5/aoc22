import std/strutils
import std/sequtils
import std/sugar

type
  # We use begin and length for Range representation to simplify calculations later
  Range = tuple[begin: int, length: int]
  Entry = tuple[first: Range, second: Range]

proc solve(entries: seq[Entry], part2 = false): int =
  var score = 0
  for e in entries:
    var r: Entry
    # Let first become the leftmost range. In case both ranges start at the same index, we consider the longest one to be first
    if e.first.begin < e.second.begin or (e.first.begin == e.second.begin and e.first.length >= e.second.length):
      r.first = e.first
      r.second = e.second
    else:
      r.first = e.second
      r.second = e.first

    if not part2:
      if r.first.length >= r.second.length + r.second.begin - r.first.begin:
        score += 1
    else:
      if r.first.begin + r.first.length - 1 >= r.second.begin:
        score += 1

  return score

func entryFromLine(line: string): Entry =
  # Get tokens and parse them as integers
  let tokens = map(line.split({',', '-'}), token => token.parseInt())
  # Init Entry
  ((tokens[0], tokens[1] - tokens[0]+1), (tokens[2], tokens[3] - tokens[2]+1))

let 
  content = readFile("./input.txt").strip().splitLines()
  entries = map(content, entryFromLine)

echo solve(entries)
echo solve(entries, true)
