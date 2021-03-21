#!/bin/bash

IFS="%"
cd "${0%/*}"
stty -echo

size=$1
food=(0 0)
snakeRender=0   # 0: Gradient, 1: Striped

declare -A snakeParts   # [index]: x,y
snakeParts=([0]=1,1 [1]=0,1)

declare -A snakeChars
snakeChars=([0]="██" [1]="▓▓" [2]="▒▒" [3]="░░" [4]="▒▒")

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
    dirChar=$(echo $1 | grep -Eo $allowedDirs | tail -1)
    if ! [[ $dirChar ]]; then return; fi
    [ $dirChar == "w" ] && dir=(0 -1)
    [ $dirChar == "a" ] && dir=(-1 0)
    [ $dirChar == "s" ] && dir=(0 1)
    [ $dirChar == "d" ] && dir=(1 0)
}

grow () {
    snakeParts[${#snakeParts[@]}]=snakeParts[$((${#snakeParts[@]} - 1))]
}

newFood () {
    until ! [[ ${snakeParts[@]} =~ $foodCoords ]]; do
        food[0]=$((RANDOM % size))
        food[1]=$((RANDOM % size))
        foodCoords="$((food[0])),$((food[1]))"
    done
}

echoChar () {  # $1: index
    case $snakeRender in
        0)
            charID=$(($1 * 4 / (${#snakeParts[@]})))
            ;;
        1)
            [ $1 -eq 0 ] && charID=0 || charID=$(((($1 - 1) / 2) % 4 + 1))
            ;;
    esac
    echo -n ${snakeChars[$charID]}
}

getCoords () {  # $1: x,y
    x=$(echo $1 | grep -Eo "^[0-9]+")
    y=$(echo $1 | grep -Eo "[0-9]+$")
}

drawWin () {
    halfY=$((($size + 1) / 2))
    halfX=$(($size - 3))
    [ $halfX -lt 1 ] && halfX=1
    tput cup $halfY $halfX
    echo -n "You Win!"
    tput cup $((size + 2)) 0
    stty echo
}

drawFrame () {
    echo -n "╔"
    for (( space=0; space < $((size * 2)); space++ )); do echo -n "═"; done
    echo "╗"
    for (( y=0; y < $size; y++ )); do
        echo "║"
    done
    for (( y=0; y < $size; y++ )); do
        tput cup $((y + 1)) $((size * 2 + 1))
        echo -n "║"
    done
    echo
    echo -n "╚"
    for (( space=0; space < $((size * 2)); space++ )); do echo -n "═"; done
    echo -n "╝"
}

drawScore () {
    scoreTxt="╡${#snakeParts[@]}/$((size * size))╞"
    spaceCount=$(($size * 2 - ${#scoreTxt} + 1))
    tput cup 0 $spaceCount
    echo $scoreTxt
}

doSnake () {
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
    [ $x -lt 0 ] && x=$((x + size)) || x=$((x % size))
    [ $y -lt 0 ] && y=$((y + size)) || y=$((y % size))
    snakeParts[0]="$x,$y"
    tput cup $((y + 1)) $((x * 2 + 1))
    ## echo -n "0"${#snakeParts[@]}
    echoChar 0
}

doFood () {
    if [ ${snakeParts[0]} == "$((food[0])),$((food[1]))" ]; then
        grow
        newFood
        drawScore
    fi
    
    tput cup $((food[1] + 1)) $((food[0] * 2 + 1))
    echo -n "◢◣"
}


clear
drawFrame
drawScore
newFood
until [ ${#snakeParts[@]} -eq $((size * size )) ]; do
    doSnake
    doFood
    tput cup $((size + 1)) $((size * 2 + 2))
    
    read -sd " " -t $(echo "e(-${#snakeParts[@]} / ($size ^ 2 / 2)) + 0.1" | bc -l) dirs
    setDir $dirs
done
doSnake
drawScore
drawWin