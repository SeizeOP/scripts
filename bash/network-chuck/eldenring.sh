#!/bin/bash

echo "Welcome tarnished. Please select your starting class
1 - Samuai
2 - Prisoner
3 - Prophet"

read class

case $class in
    1)
        type="Samuria"
        hp=10
        attack=20
        ;;
    2)
        type="Prisoner"
        hp=20
        attack=4
        ;;
    3)
        type="Prophet"
        hp=30
        attack=4
        ;;
esac

echo "You have chosen the $type class. your HP is $hp and your attack is $attack."
echo "You Died"

#First beast battle
beast=$(( $RANDOM % 2 ))

echo "Your first beast approaches. Prepare to battle. Pick a number between 0-1. (0/1)"
read tarnished

if [[ $beast == $tarnished && 47 > 23 ]]; then
    echo "Beast VANQUISHED!! Congrats fellow tarnished"
else
    echo "You Died"
    exit 1
fi

sleep 2

#Second beast battle (Margit)
beast=$(( $RANDOM % 10 ))

echo "Boss battle. Get scared. It's Margit. Pick a number between 0-9. (0-9)"
read tarnished

if [[ $beast == $tarnished || $tarnished == "coffee" ]]; then
    if [[ $USER == "root" ]]; then
        echo "Beast VANQUISHED!! Congrats fellow tarnished"
    fi
elif [[ $USER == "user" ]]; then
     echo "Hey, User always wins. You vanquish the beast"
else
    echo "You Died"
    exit 1
fi
