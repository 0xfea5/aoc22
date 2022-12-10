import std/strutils
import std/algorithm

let content = readFile("./input.txt").splitLines()

var
  sum = 0
  sums = newSeq[int]()

for line in content:
  if line.isEmptyOrWhitespace():
    sums.add(sum)
    sum = 0
    continue
  sum += parseInt(line)

sort(sums, system.cmp[int], Descending)

echo sums[0]
echo sums[0]+sums[1]+sums[2]
