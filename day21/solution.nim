import strutils
import sequtils
import tables
import strformat

type
  Node = ref object of RootObj
    left, right: string
    val: int

  AddNode = ref object of Node
  SubNode = ref object of Node
  MulNode = ref object of Node
  DivNode = ref object of Node

var nodes: Table[string, Node]

method calc(node: Node): int =
  node.val

method calc(node: AddNode): int = 
  nodes[node.left].calc() + nodes[node.right].calc()

method calc(node: SubNode): int = 
  nodes[node.left].calc() - nodes[node.right].calc()

method calc(node: MulNode): int = 
  nodes[node.left].calc() * nodes[node.right].calc()

method calc(node: DivNode): int = 
  nodes[node.left].calc() div nodes[node.right].calc()

proc `$`(node: Node): string =
  fmt"val: {node.val}, left: {node.left}, right: {node.right}"

proc parseLine(line: string): void =
  let tokens = line.split(": ")
  let id = tokens[0]
  let ops = tokens[1].split(" ")

  # if single token -> its a number
  if ops.len() == 1:
    nodes[id] = Node(val: ops[0].parseInt())
  else:
    let left = ops[0]
    let right = ops[2]
    case ops[1]:
      of "+":
        nodes[id] = AddNode(left: left, right: right)
      of "-":
        nodes[id] = SubNode(left: left, right: right)
      of "*":
        nodes[id] = MulNode(left: left, right: right)
      of "/":
        nodes[id] = DivNode(left: left, right: right)
      else:
        assert(false)

proc parseFile(): void =
  let lines = readFile("./input.txt").strip().splitLines()

  for line in lines:
    parseLine(line)

parseFile()
echo nodes["root"].calc()
