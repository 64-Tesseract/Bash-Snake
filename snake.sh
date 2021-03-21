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

dir=(1 0)


setDir () {  # $1: w/a/s/d list
    dirStr="$((dir[0])),$((dir[1]))"
    case $dirStr in
        "0,-1")
            allowedDirs="[w|a|d]"
            ;;
        "-1,0")
            allowedDirs="[w|a|s]"
            ;;
        "0,1")
            allowedDirs="[a|s|d]"
            ;;
        "1,0")
            allowedDirs="[w|s|d]"
            ;;
    esac
    dirs=$(echo $1 | rev | grep -Eo "$allowedDirs" | grep -Eo "^.")
    ## echo -n "$allowedDirs $dirs"
    case $dirs in
        w)
            dir=(0 -1)
            ;;
        a)
            dir=(-1 0)
            ;;
        s)
            dir=(0 1)
            ;;
        d)
            dir=(1 0)
            ;;
    esac
}

echoChar () {  # $1: index
    charID=$(($1 * 3 / (${#snakeParts[@]} - 1)))
    echo -n ${snakeChars[$charID]}
}

getCoords () {  # $1: x,y
    x=$(echo $1 | grep -Eo "^[0-9]+")
    y=$(echo $1 | grep -Eo "[0-9]+$")
}

drawFrame () {
    echo -n "╔"
    for (( space=0; space <= $((size * 2)); space++ )); do echo -n "═"; done
    echo "╗"
    for (( y=0; y < $size; y++ )); do
        echo "║"
    done
    for (( y=0; y < $size; y++ )); do
        tput cup $((y + 1)) $((size * 2 + 2))
        echo -n "║"
    done
    echo
    echo -n "╚"
    for (( space=0; space <= $((size * 2)); space++ )); do echo -n "═"; done
    echo -n "╝"
}

drawScore () {
    # TODO: Everything
    scoreTxt="╡$score╞"
    spaceCount=$(($size * 2 - ${#scoreTxt}))
    for (( space=0; space <= spaceCount; space++ )); do echo -n "═"; done
    echo $scoreTxt
}

doSnake () {
    tput cup 0 0
    echo -n ${#snakeParts[@]}
    for (( bIndex=$((${#snakeParts[@]} - 1)); bIndex > 0; bIndex-- )); do
        if [ $bIndex -eq $((${#snakeParts[@]} - 1)) ]; then
            getCoords ${snakeParts[$bIndex]}
            tput cup $((y + 1)) $((x * 2 + 1))
            echo -n "  "
        fi
        snakeParts[$bIndex]=${snakeParts[$((bIndex - 1))]}
        getCoords ${snakeParts[$bIndex]}
        tput cup $((y + 1)) $((x * 2 + 1))
        ## echo -n $bIndex" "
        echoChar $bIndex
    done
    
    getCoords ${snakeParts[0]}
    x=$((x + dir[0]))
    y=$((y + dir[1]))
    snakeParts[0]="$x,$y"
    tput cup $((y + 1)) $((x * 2 + 1))
    ## echo -n "0"${#snakeParts[@]}
    echoChar 0
}


clear
drawFrame   
while [ 1 ]; do
    doSnake
    
    read -sd "" -t 1 dirs
    setDir $dirs
done