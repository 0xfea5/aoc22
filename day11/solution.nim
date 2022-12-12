import strutils
import sequtils
import algorithm
import sugar
import re

type
  Operation = tuple
    operator: char
    operand: int64

  Monkey = tuple
    items: seq[int64]
    operation: Operation
    test: int64
    success: int
    failure: int
    score: int64

func parseFile(content: string): seq[Monkey] =
  let monkeysStr = content.split("\n\n")

  for monkeyStr in monkeysStr:
    let tokens = monkeyStr.splitLines()
    # list of numbers eg: [5, 13, 45]
    let items = map(tokens[1].replace(re"[^0-9\,]").split(","), (snum) => int64(snum.parseInt()))
    # operator followed by operand eg: "+6"
    let operationStr = tokens[2].replace(re"[^0-9\+\-\*]")
    var operation: Operation
    try:
      operation = (operationStr[0], int64(operationStr[1 .. ^1].parseInt()))
    except:
      operation = (operationStr[0], int64(0))
    # test number eg: 13
    let test = tokens[3].replace(re"[^0-9]").parseInt()
    # divisor number eg: 3
    let success = tokens[4].replace(re"[^0-9]").parseInt()
    let failure = tokens[5].replace(re"[^0-9]").parseInt()

    result.add((items, operation, int64(test), success, failure, int64(0)))

var LCM: int64
var part2 = false
proc calc(item: int64, op: Operation): int64 =
  var operation = op
  if operation.operand == 0:
    operation.operand = item

  case operation.operator:
    of '+':
      result = item + operation.operand
    of '-':
      result = item - operation.operand
    of '*':
      result = item * operation.operand
    else:
      assert(false)

  if part2:
    result = result mod LCM

proc doRound(monkeys: var seq[Monkey]): void =
  for monkey in monkeys.mitems():
    for item in monkey.items:
      var nextItem: int64
      if not part2:
        nextItem = calc(item, monkey.operation) div 3
      else:
        nextItem = calc(item, monkey.operation)
      monkey.score += 1
      if nextItem mod monkey.test == 0:
        monkeys[monkey.success].items.add(nextItem)
      else:
        monkeys[monkey.failure].items.add(nextItem)
    monkey.items = @[]

proc emulate(monkeys: seq[Monkey], rounds: int, part2 = false): int64 =
  var monkeys = monkeys
  for round in 1 .. rounds:
    doRound(monkeys)

  monkeys.sort((lhs, rhs) => lhs.score < rhs.score)
  let best = map(monkeys, (monkey) => monkey.score)[0..<2]
  best[0] * best[1]

func gcd(a, b: int64): int64 =
  var
    a = a
    b = b
  if a < b:
    swap(a, b)

  while a != 0 and b != 0:
    let r = a mod b
    a = b
    b = r
  return a

let content = readFile("./input.txt").strip()
let monkeys = parseFile(content)

LCM = monkeys[0].test
for monkey in monkeys:
  LCM = monkey.test div gcd(LCM, monkey.test) * LCM

echo emulate(monkeys, 20)
part2 = true
echo emulate(monkeys, 10_000, true)
