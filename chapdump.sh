#!/bin/sh
target=$1

a = ["redirect",
"source",
"count",
"describe",
"enumerate",
"explain",
"list",
"show",
"summarize",
]

b = [allocation
allocations
anchored
anchorpoints
chain
exactincoming
externalanchored
externalanchorpoints
free
freeoutgoing
incoming
leaked
modules
outgoing
registeranchored
registeranchorpoints
reversechain
stackanchored
stackanchorpoints
stacks
staticanchored
staticanchorpoints
threadcached
threadonlyanchored
threadonlyanchorpoints
unreferenced
used
]

for i in $(echo $a[@])
do
    for j in $(echo $b[@]); do

echo "$i $j" | chap ./$target-core >> $target-core-$i-$j;

    done
done

