import std/strutils
import std/algorithm
import std/strformat

let input = readFile("./input.txt").split({'\n'})

var 
  sum : int
  sums: seq[int]

for line in input:
  if line.isEmptyOrWhitespace():
    sums.add(sum)
    sum = 0
    continue
  sum += parseInt(line)

sort(sums, system.cmp[int], Descending)

echo fmt"Part 1: {sums[0]}"
echo fmt"Part 2: {sums[0]+sums[1]+sums[2]}"
