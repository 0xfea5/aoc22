import std/strutils
import std/sequtils
import std/sets

proc Points(c: char): int =
  if c.isLowerAscii():
    return ord(c) - ord('a') + 1
  else:
    return ord(c) - ord('A') + 27

proc part1(content: seq[string]): int =
  let ruckshacks = map( content,
      proc(line: string): tuple[first: string, second: string] = 
        let pivot = int(line.len()/2)
        (line[0 .. pivot-1], line[pivot .. ^1])
    )

  var score = 0
  for ruckshack in ruckshacks:
    let
      uniqFirst = toHashSet(ruckshack.first)
      uniqSecond = toHashSet(ruckshack.second)

    var c = toSeq(uniqFirst * uniqSecond)[0]
    score += Points(c)

  return score

proc part2(content: seq[string]): int =
  assert(content.len() mod 3 == 0)
 
  let ruckshacks = content
  var score = 0
  for i in countup(0, ruckshacks.len()-1, 3):
    let 
      uniqFirst = toHashSet(ruckshacks[i])
      uniqSecond = toHashSet(ruckshacks[i+1])
      uniqThird = toHashSet(ruckshacks[i+2])

    var c = toSeq(uniqFirst * uniqSecond * uniqThird)[0]
    score += Points(c)

  return score

let content = readFile("./input.txt").strip().split("\n")
echo part1(content)
echo part2(content)
