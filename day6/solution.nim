import std/strutils
import std/sequtils
import std/enumerate
import std/tables

proc solve(message: string, nUniq: int): int =
  var cntUniq = initCountTable[char]()
  
  # init found
  var uniq = 0
  for c in message[0 ..< nUniq]:
    cntUniq.inc(c)
    if cntUniq[c] == 1:
      uniq += 1

  let pairs = zip(
    message[0 ..< message.len()-nUniq],
    message[nUniq ..< message.len()])

  for i, pair in enumerate(pairs):
    if uniq == nUniq:
      return i+nUniq

    cntUniq.inc(pair[0], -1)
    if cntUniq[pair[0]] == 0:
      # we lost one uniq number in sequence
      uniq -= 1

    cntUniq.inc(pair[1])
    if cntUniq[pair[1]] == 1:
      # we found new uniq number in sequence
      uniq += 1

  assert(false)
  return -1

let content = readFile("./input.txt").strip()

echo solve(content, 4)
echo solve(content, 14)
