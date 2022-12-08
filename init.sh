#!/bin/sh
source ../cookie.sh

if [ $# -eq 0 ]
then
  echo "No arguments provided."
  exit 1
fi

DAY=$1
DIR="day$DAY"
echo "Initializing day $DAY in directory $DIR"

mkdir -p $DIR && curl "https://adventofcode.com/2022/day/$DAY/input" -H "Cookie: session=$ADVENT_SESSION" > $DIR/input.txt
touch $DIR/solution.nim
