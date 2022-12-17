import strutils
import sequtils
import re
import tables
import strformat
import algorithm

type
  NodeData = tuple
    pressure: int
    neighbors: seq[string]

  Node = tuple
    id: string
    data: NodeData

  NodeGraph = Table[string, NodeData]

  ExtendedNodeData = tuple
    pressure: int
    neighbors: Table[string, int]

  ExtendedNodeGraph = Table[string, ExtendedNodeData]

proc parseLine(line: string): Node =
  let tokens = line.replace("Valve ")
                   .replace("has flow rate=")
                   .replace(re"; tunnels? leads? to valves?")
                   .replace(", ", " ")
                   .split(" ")
  (tokens[0], (tokens[1].parseInt(), @tokens[2..^1]))

proc parseFile(content: string): NodeGraph =
  let lines = content.strip().splitLines()
  let nodes = map(lines, parseLine)

  for node in nodes:
    result[node.id] = node.data

proc bfs(input: NodeGraph, src: string): Table[string, int] =
  var q = @[(src, 0)]
  result[src] = 0

  while q.len() > 0:
    let (curr, pathLen) = q[0]
    q.delete(0)

    for neighbor in input[curr].neighbors:
      if result.contains(neighbor):
        continue
      result[neighbor] = pathLen+1
      q.add((neighbor, pathLen+1))

proc setup(input: NodeGraph): ExtendedNodeGraph =
  for node in input.keys():
    # Exclude all 0 pressure nodes except the entry node "AA"
    if (input[node].pressure == 0 and node != "AA"):
      continue
    let allConnected = bfs(input, node)
    var filtConnected: Table[string, int]
    for conn in allConnected.keys():
      if input[conn].pressure == 0:
        continue
      filtConnected[conn] = allConnected[conn]

    result[node] = (input[node].pressure, filtConnected)
    # echo fmt"{node} : {result[node]}"


var dp: Table[string, int]
proc normalize(visited: string): string =
  var s: seq[string]
  for i in countup(0, visited.len()-1, 2):
    s.add(visited[i..i+1])
  result = s.sorted(system.cmp[string]).join()

proc dfs(input: ExtendedNodeGraph, src: string, visited: string, time: int): int =
  if time <= 1 or visited.len() == input.len():
    return 0

  # if dp.contains(visited):
  #   return dp[visited]

  let visitedNorm = visited.normalize()
  let selfScore = (time-1) * input[src].pressure
  var maxSubscore = 0
  var maxNeighbor = "undefined" 
  # echo fmt"{src}({selfScore}): "
  for neighbor in input[src].neighbors.keys():
    if neighbor in visited:
      continue
    let distance = input[src].neighbors[neighbor]
    let subScore = dfs(input, neighbor, visitedNorm & neighbor, time - 1 - distance)
    if subScore > maxSubscore:
      maxSubscore = subScore
      maxNeighbor = neighbor

  # echo fmt"{src}({selfScore}) => {maxNeighbor}({maxSubscore})"
  result = selfScore + maxSubscore
  # dp[visitedNorm & maxNeighbor] = result
  # echo result

proc solve(input: NodeGraph, time: int): int =
  let completeGraph = setup(input)
  # Table of delays to get from starting node "AA" to current
  let initDelays = completeGraph["AA"].neighbors

  for node in completeGraph.keys():
    if node == "AA":
      continue
    let startTime = time - initDelays[node]
    result = max(result, dfs(completeGraph, node, node, startTime))
    echo fmt"{node}({startTime}) : {result}"

let content = readFile("./example.txt")

let input = parseFile(content)
echo solve(input, 30)
