#!/bin/bash

IFS="%"
cd "${0%/*}"

size=$1
score=0
food=($((size * 2 / 3)) $((size / 2)))

declare -A snakeParts   # [index]: x,y
snakeParts=([0]=2,1 [1]=1,1)

declare -A snakeChars
snakeChars=([0]="██" [1]="▓▓" [2]="▒▒" [3]="░░")


echoChar () {  # $1: index
    charID=$(($1 * 3 / (${#snakeParts} - 2)))
    echo -n ${snakeChars[$charID]}
}

render () {
    clear
    
    # Top bar
    echo -n "╔"
    scoreTxt="╡$score╞╗"
    spaceCount=$(($size * 2 - ${#scoreTxt}))
    for (( space=0; space <= spaceCount; space++ )); do echo -n "═"; done
    echo $scoreTxt
    
    for (( bIndex=0; bIndex < ${#snakeParts}; bIndex++ )); do
        x=$(echo ${snakeParts[$bIndex]} | grep -Eo "^[0-9]+")
        y=$(echo ${snakeParts[$bIndex]} | grep -Eo "[0-9]+$")
        tput cup $((y + 1)) $((x * 2 + 1))
        echoChar $bIndex
    done
}


while [ 1 ]; do
    render
    
    read -sd "" -t 1 dirs
done