import std/strutils
import std/sequtils
import std/enumerate
import std/algorithm
import std/re

type
  Move = tuple 
    Amount: int
    From: int
    To: int

  Stack = seq[char]

  Input = tuple
    Stacks: seq[Stack]
    Moves: seq[Move]

proc parseContent(content: string): Input =
  # Parse stacks
  let tokens = content.split("\n\n")
  var strStacks = map(
      # All lines containing characters of the stacks 
      # Exclude last line since it contain's each stack's id
      tokens[0].splitLines()[0 .. ^2],
      proc(line: string): string =
        var retval = ""
        # keep only the relevant characters (spaces/letters)
        for i in countup(1, line.len(), 4):
          retval.add(line[i])
        retval
      )

  var Stacks = newSeq[Stack](10)

  for layer in strStacks:
    for i, c in enumerate(layer):
      if c != ' ':
        Stacks[i+1].add(c)

  var strMoves = map(
      # All moves described in the input
      tokens[1].strip().splitLines(),
      proc(line: string): seq[int] = 
        # Remove words and split on spaces
        let tokens = line.replace(re"[a-z]+ ").split(" ")
        # Parse them as integers
        map(tokens, proc (num: string): int = num.parseInt())
      )

  var Moves: seq[Move]
  for move in strMoves:
    Moves.add((move[0], move[1], move[2]))

  return (Stacks, Moves)

proc makeMove(stacks: var seq[Stack], move: Move, inPlace = false): void =
  # copy top of the stack
  var yoink = stacks[move.From][0 ..< move.Amount]
  # moving in place preserves the order of the moved crates (part2)
  if not inPlace:
    yoink.reverse()
  # remove it from origin
  stacks[move.From].delete(0 ..< move.Amount)
  # concat it in front of destination
  stacks[move.To] = concat(yoink, stacks[move.To])

proc getAnswer(stacks: seq[Stack]): string =
  var answer = ""
  for stack in stacks:
    if stack.len() > 0:
      answer.add(stack[0])
  answer

let content = readFile("./input.txt")
var input = parseContent(content)

let moves = input.Moves
var stacksPart1 = input.Stacks
var stacksPart2 = input.Stacks

for move in moves:
  makeMove(stacksPart1, move)
  makeMove(stacksPart2, move, true)

echo getAnswer(stacksPart1)
echo getAnswer(stacksPart2)
