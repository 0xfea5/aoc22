import strutils
import sequtils
import re
import tables
import strformat
import algorithm
import sets
import sugar

type
  NodeData = tuple
    pressure: int
    neighbors: seq[int64]

  Node = tuple
    id: int64
    data: NodeData

  NodeGraph = Table[int64, NodeData]

  ExtendedNodeData = tuple
    pressure: int
    neighbors: Table[int64, int]

  ExtendedNodeGraph = Table[int64, ExtendedNodeData]

proc parseLine(line: string): auto =
  let tokens = line.replace("Valve ")
                   .replace("has flow rate=")
                   .replace(re"; tunnels? leads? to valves?")
                   .replace(", ", " ")
                   .split(" ")
  (tokens[0], (tokens[1].parseInt(), @tokens[2..^1]))

proc parseFile(content: string): NodeGraph =
  let lines = content.strip().splitLines()
  let nodes = map(lines, parseLine)

  # Create stringID to intID mapping
  var nodeIDs: Table[string, int64]
  for i, node in nodes:
    nodeIDs[node[0]] = 1 shl i

  echo nodeIDs
  # for i, node in nodes:
  #   result[nodeIDs[nodes[0]]] = (node[1][0], map(node[1][1], (stringID) => nodeIDs[stringID]))

# proc bfs(input: NodeGraph, src: string): Table[string, int] =
#   var q = @[(src, 0)]
#   result[src] = 0
#
#   while q.len() > 0:
#     let (curr, pathLen) = q[0]
#     q.delete(0)
#
#     for neighbor in input[curr].neighbors:
#       if result.contains(neighbor):
#         continue
#       result[neighbor] = pathLen+1
#       q.add((neighbor, pathLen+1))
#
# proc setup(input: NodeGraph): ExtendedNodeGraph =
#   for node in input.keys():
#     # Exclude all 0 pressure nodes except the entry node "AA"
#     if (input[node].pressure == 0 and node != "AA"):
#       continue
#     let allConnected = bfs(input, node)
#     var filtConnected: Table[string, int]
#     for conn in allConnected.keys():
#       if input[conn].pressure == 0:
#         continue
#       filtConnected[conn] = allConnected[conn]
#
#     result[node] = (input[node].pressure, filtConnected)
#     # echo fmt"{node} : {result[node]}"
#
# type Agent = tuple
#   valv: string
#   time: int
#
# # Nodes with their neighbors
# var Graph: ExtendedNodeGraph
# # Node names
# var nodes = newSeq[string]()
#
# proc playing(agent: Agent, time: int): bool =
#   agent.time == time
#
# proc agentScores(agent: Agent, time: int): int =
#   Graph[agent.valv].pressure * (time-1)
#
# type ValveSet = uint64
#
# proc incl(set: var ValveSet, valve: uint64): void =
#   set = set or valve
#
# proc contains(set: ValveSet, valve: uint64): bool =
#   return (set and valve) > 0
#
# var part2 = false
# proc dfs(visited: ValveSet, time: int, human, elephant: Agent): int =
#   # echo fmt"time: {time}, human: {human}, elephant: {elephant}"
#   let remainingValves = nodes.len() - visited.len() 
#   if time <= 1 or remainingValves == 0 or (part2 and human.valv == elephant.valv and remainingValves > 1):
#     return 0
#
#   let
#     neighborsHuman = Graph[human.valv].neighbors
#     neighborsElephant = Graph[elephant.valv].neighbors
#   var
#     # check for race
#     humanScore = if human.valv notin visited: human.agentScores(time) else: 0
#     elephantScore = if elephant.valv notin visited: elephant.agentScores(time) else: 0
#
#   var bestNextScore = 0
#   if human.playing(time) and elephant.playing(time):
#     for nextHuman in nodes:
#       for nextElephant in nodes:
#         if nextHuman in visited or nextElephant in visited:
#           continue
#         let
#           nextTimeHuman = time - 1 - neighborsHuman[nextHuman]
#           nextTimeElephant = time - 1 - neighborsElephant[nextElephant]
#           nextTime = max(nextTimeHuman, nextTimeElephant)
#           nextScore = dfs(union(visited, toHashSet(@[elephant.valv, human.valv])), nextTime, (nextHuman, nextTimeHuman), (nextElephant, nextTimeElephant))
#         bestNextScore = max(bestNextScore, nextScore)
#
#     # elephant keeps his score only if he isn't in the same valve as human
#     elephantScore = (if human != elephant: elephantScore else: 0)
#     return bestNextScore + humanScore + elephantScore
#
#   if human.playing(time):
#     for nextHuman in nodes:
#       if nextHuman in visited:
#         continue
#       let
#         nextTimeHuman = time - 1 - neighborsHuman[nextHuman]
#         nextTime = max(nextTimeHuman, elephant.time)
#         nextScore = dfs(union(visited, toHashSet(@[human.valv])), nextTime, (nextHuman, nextTimeHuman), elephant)
#       bestNextScore = max(bestNextScore, nextScore)
#
#     # Check for race
#     return bestNextScore + humanScore
#
#   if elephant.playing(time):
#     for nextElephant in nodes:
#       if nextElephant in visited:
#         continue
#       let
#         nextTimeElephant = time - 1 - neighborsElephant[nextElephant]
#         nextTime = max(human.time, nextTimeElephant)
#         nextScore = dfs(union(visited, toHashSet(@[elephant.valv])), nextTime, human, (nextElephant, nextTimeElephant))
#       bestNextScore = max(bestNextScore, nextScore)
#
#     # Check for race
#     return bestNextScore + elephantScore
#   
#   assert(false)
#
# proc solve(initDelays: Table[string, int], time: int): int =
#
#   if not part2:
#     for human in nodes:
#       let
#         humanStartTime = time - initDelays[human]
#         startTime = humanStartTime
#       result = max(result, dfs(initHashSet[string](), startTime, (human, humanStartTime), (human, -1)))
#   else:
#     for i, human in nodes[0 ..< ^1]:
#       for elephant in nodes[i+1 .. ^1]:
#         let
#           elephantStartTime = time - initDelays[elephant]
#           humanStartTime = time - initDelays[human]
#           startTime = max(elephantStartTime, humanStartTime)
#         result = max(result, dfs(initHashSet[string](), startTime, (human, humanStartTime), (elephant, elephantStartTime)))
#
#

let content = readFile("./example.txt")
let input = parseFile(content)
echo input

# # Table of delays to get from starting node "AA" to current
# let initDelays = Graph["AA"].neighbors
# Graph.del("AA")
#
# for node in Graph.keys():
#   nodes.add(node)
#
# echo solve(initDelays, 30)
# part2 = true
# echo solve(initDelays, 26)
