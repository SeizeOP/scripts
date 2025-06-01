#!/usr/bin/env sh

x=1

while [[ $x -le 10 ]]
do
    read -p "Pushup $x: Press Enter to continue"
    (( x ++ ))
done
echo "Congrats, you completed your pushups!!"
