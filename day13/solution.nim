import strutils
import strformat
import algorithm

type
  Data = ref object
    val: int
    list: seq[Data]

  Packet = tuple
    first: Data
    second: Data

  Input = seq[Packet]

proc `$`(data: Data): string =
  if data.val != -1:
    return fmt"{data.val}"

  result = "[" & data.list.join(",") & "]"

proc parseData(strData: string, i: var int): Data =
  result = Data(val: -1, list: newSeq[Data]())
  let dataLen = strData.len()
  while i < dataLen:
    case strData[i]:
      of '[':
        i += 1
        result.list.add(parseData(strData, i))
      of ']':
        i += 1
        return result
      of ',':
        i += 1
      else:
        var j = i
        while j < dataLen and strData[j].isDigit():
          j += 1;
        let toPush = Data(val: strData[i..<j].parseInt())
        result.list.add(toPush)
        i = j

proc parsePacket(strPacket: string): Packet =
  let strDatas = strPacket.splitLines()
  assert(strDatas.len() == 2)
  var
    i0 = 0
    i1 = 0
  result = (parseData(strDatas[0][1..^2], i0), parseData(strDatas[1][1..^2], i1))

proc parseFile(content: string): Input =
  let strPackets = content.strip().split("\n\n")

  for strPacket in strPackets:
    result.add(parsePacket(strPacket))

proc compare(A, B: int): int =
  if A < B: return -1
  elif A > B: return 1
  else: return 0

proc dataListForm(data: Data): Data =
  # Check if its already in list form
  if data.val == -1:
    return data
  result = Data(val: -1, list: @[data])

proc compare(A, B: Data): int =
  # Both numbers:
  if A.val != -1 and B.val != -1:
    return compare(A.val, B.val)

  # Transform both data to list form
  let
    A = dataListForm(A)
    B = dataListForm(B)

  assert(A.val == -1 and B.val == -1)
  # Both are lists now
  let
    li = A.list.len()
    lj = B.list.len()
    N = min(li, lj)

  var i = 0
  while i < N:
    let res = compare(A.list[i], B.list[i])
    if res != 0:
      return res
    i += 1

  return compare(li, lj)

proc part1(Packets: Input): int =
  for i, packet in Packets:
    # echo fmt"Checking packet {packet}"
    let comparison = compare(packet.first, packet.second)
    # echo fmt"result = {comparison}"
    if comparison < 0:
      result += i+1

proc part2(Packets: Input): int =
  let driverPackets = parseFile("[[6]]\n[[2]]\n")
  let first = driverPackets[0].first
  let second = driverPackets[0].second
  var datas = @[first, second]

  for packet in Packets:
    datas.add(packet.first)
    datas.add(packet.second)

  datas.sort(compare)
  let firstIndex = datas.binarySearch(first, compare) + 1
  let secondIndex = datas.binarySearch(second, compare) + 1
  return firstIndex * secondIndex

let content = readFile("./input.txt")
let input = parseFile(content)

echo part1(input)
echo part2(input)
