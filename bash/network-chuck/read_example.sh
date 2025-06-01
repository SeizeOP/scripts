#!/usr/bin/env sh

x=1

while read -r line; do
echo "line $x $line"
(( x ++ ))
done < hamlet
