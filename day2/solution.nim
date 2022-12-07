import std/strutils
import std/sequtils
import std/tables

let content = readFile("./input.txt").split("\n")
let rounds = map(
    # Filter out empty lines
    filter(content, proc(line: string): bool = not line.isEmptyOrWhitespace()),
    # Split line into pair of strings
    proc(round: string): tuple[other: char, self: char] = 
       var splitted = round.split(" ")
       (splitted[0][0], splitted[1][0]))

# example: rounds = [('A', 'Z'), ('C', 'Y')]
# echo rounds

proc solve(dScore: array[3, array[3, int]]): int = 
    var score = 0
    for round in rounds:
        let
            i = ord(round.other) - ord('A')
            j = ord(round.self) - ord('X')
        score += dScore[i][j]

    return score

let pt1 = [
    # A = Rock
    # X Y Z
    [1 + 3, 2 + 6, 3 + 0],
    # B = Paper
    # X Y Z
    [1 + 0, 2 + 3, 3 + 6],
    # C = Scissors
    # X Y Z
    [1 + 6, 2 + 0, 3 + 3],
]

echo solve(pt1)

let pt2 = [
    # A = Rock
    # X Y Z
    [3 + 0, 1 + 3, 2 + 6],
    # B = Paper
    # X Y Z
    [1 + 0, 2 + 3, 3 + 6],
    # C = Scissors
    # X Y Z
    [2 + 0, 3 + 3, 1 + 6],
]

echo solve(pt2)
