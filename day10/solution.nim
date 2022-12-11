import strutils
import sequtils
import sugar

type
  Instruction = tuple
    opcode: string
    arg: int

  Program = seq[Instruction]

func instructionFromString(str: string): Instruction =
  let tokens = str.split()
  let opcode = tokens[0]
  var arg: int
  if tokens.len() > 1:
    arg = tokens[1].parseInt()
  else:
    arg = 0
  
  (opcode, arg)

func parseProgram(content: seq[string]): Program =
  result = map(
    content,
    (line) => instructionFromString(line)
  )

proc checkSignal(cycle: int, x: int): int =
  # cycle+1 because cycle is supposed to be starting at 0
  if cycle+1 in [20, 60, 100, 140, 180, 220]:
    result = x * (cycle+1)

var CRT: array[0 .. 5, array[0 .. 39, char]]
proc draw(cycle: int, x: int): void =
  let
    col = cycle mod 40
    row = cycle div 40
  if col in [x-1, x, x+1]:
    CRT[row][col] = '#'

proc execute(program: Program): int =
  var
    x = 1
    cycle = 0

  for i, instr in program:
    result += checkSignal(cycle, x)
    draw(cycle, x)
    case instr.opcode:
      of "addx":
        result += checkSignal(cycle+1, x)
        draw(cycle+1, x)
        x += instr.arg
        cycle += 2
      of "noop":
        cycle += 1
      else:
        assert(false)

let content = readFile("./input.txt").strip().splitLines()
let program = parseProgram(content)

for row in 0 ..< 6:
  for col in 0 ..< 40: 
    CRT[row][col] = ' '

echo execute(program)
for row in CRT:
  echo row.join()
