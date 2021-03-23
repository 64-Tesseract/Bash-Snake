#!/bin/bash

IFS="%"
# cd "${0%/*}"
stty -echo

if ! [[ $1 ]]; then size=8; else size=$1; fi
if ! [[ $2 ]]; then snakeStyle=0; else snakeStyle=$2; fi
if ! [[ $3 ]]; then loop=0; else loop=$3; fi

food=(0 0)
lr=1

declare -A snakeParts   # [index]: c`x`,`y`,`dir`c
snakeParts=([0]="c1,1,dc" [1]="c0,1,dc")

declare -A snakeChars
snakeChars=([-2]="█▀" [-1]="█▄" [0]="█" [1]="▓" [2]="▒" [3]="░" [4]="▒")


setDir () {  # $1: w/a/s/d list
    # Generate set of valid directions (not backwards) & set left-right for rendering head
    getCoords ${snakeParts[0]}
    case $dir in
        "w")
            allowedDirs="[w|a|d]"
            ;;
        "a")
            allowedDirs="[w|a|s]"
            lr=0
            ;;
        "s")
            allowedDirs="[a|s|d]"
            ;;
        "d")
            allowedDirs="[w|s|d]"
            lr=1
            ;;
    esac

    # Get latest character from list of valid directions
    dirChar=$(echo $1 | grep -Eo $allowedDirs | tail -1)
    if ! [[ $dirChar ]]; then return; fi
    snakeParts[0]=c"$x,$y,$dirChar"c
}

grow () {
    snakeParts[${#snakeParts[@]}]=${snakeParts[$((${#snakeParts[@]} - 1))]}
}

newFood () {
    until ! [[ ${snakeParts[@]} =~ $foodCoords ]]; do  # Generate random coords until in open space
        food[0]=$((RANDOM % size))
        food[1]=$((RANDOM % size))
        foodCoords="$((food[0])),$((food[1]))"
    done
    tput cup $((food[1] + 1)) $((food[0] * 2 + 1))
    echo -n "◢◣"
}

echoHead () {
    getCoords ${snakeParts[0]}
    if [ $snakeStyle -ge 2 ]; then
        case $dir in  # Head will rotate with orientation & last horizontal facing
            "w")
                [ $lr -eq 1 ] && echo -n ${snakeChars[-1]} | rev || echo -n ${snakeChars[-1]}
                ;;
            "a")
                echo -n ${snakeChars[-1]} | rev
                ;;
            "s")
                [ $lr -eq 1 ] && echo -n ${snakeChars[-2]} || echo -n ${snakeChars[-2]} | rev
                ;;
            "d")
                echo -n ${snakeChars[-1]}
                ;;
        esac
    else
        echo -n ${snakeChars[0]}${snakeChars[0]}
    fi
}

echoBody () {  # $1: Index
    case $snakeStyle in
        "0" | "2")
            char=${snakeChars[$((($1 - 1) * 4 / (${#snakeParts[@]} - 1)))]}
            ;;
        "1" | "3")
            char=${snakeChars[$((1 + ($1 / 3 - 1) % 4))]}
            ;;
    esac
    if [ $snakeStyle -ge 2 ] && [ $((${#snakeParts[@]} - 1)) -eq $1 ]; then
        getCoords ${snakeParts[$(($1 - 2))]}
        nextDir=$dir
        getCoords ${snakeParts[$1]}
        if ! [[ $nextDir ]]; then  # Tail will always be on side opposite of turning
            echo -n $char$char
        elif [ $dir == "a" ]; then
            echo -n "$char "
        elif [ $dir == "d" ]; then
            echo -n " $char"
        elif [ $nextDir == "a" ]; then
            echo -n " $char"
        elif [ $nextDir == "d" ]; then
            echo -n "$char "
        elif [ $dir == "w" ]; then
            echo -n "$char "
        elif [ $dir == "s" ]; then
            echo -n " $char"
        fi
    else
        echo -n $char$char
    fi
}

getCoords () {  # $1: c`x`,`y`,`dir`c
    x=$(echo $1 | grep -Eo "c[0-9]+," | grep -Eo "[0-9]+")
    y=$(echo $1 | grep -Eo ",[0-9]+," | grep -Eo "[0-9]+")
    dir=$(echo $1 | grep -Eo "[w|a|s|d]")
}

drawWin () {  # $1: 1 if win, 2 if loss
    halfY=$((($size + 1) / 2))
    [ $1 -eq 1 ] && halfX=$((size - 3)) || halfX=$((size - 4))
    [ $halfX -lt 1 ] && halfX=1
    tput cup $halfY $halfX
    [ $1 -eq 1 ] && echo -n "You Win!" || echo -n "Game Over!"
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
    getCoords ${snakeParts[0]}
    case $dir in
        "w")
            headY=$((y - 1))
            headX=$x
            ;;
        "a")
            headX=$((x - 1))
            headY=$y
            ;;
        "s")
            headY=$((y + 1))
            headX=$x
            ;;
        "d")
            headX=$((x + 1))
            headY=$y
            ;;
    esac
    headDir=$dir

    # Calculate wall collisions, but don't render anything if game over
    if [ $loop -eq 1 ]; then
        [ $headX -lt 0 ] && headX=$((headX + size)) || headX=$((headX % size))
        [ $headY -lt 0 ] && headY=$((headY + size)) || headY=$((headY % size))
    else
        if [ $headX -eq -1 ] || [ $headX -eq $size ] || [ $headY -eq -1 ] || [ $headY -eq $size ]; then endGame=2; return; fi
    fi

    # Move & render all body parts in reverse order
    for (( bIndex=$((${#snakeParts[@]} - 1)); bIndex > 0; bIndex-- )); do
        if [ $bIndex -eq $((${#snakeParts[@]} - 1)) ]; then  # Clear old tail pos
            getCoords ${snakeParts[$bIndex]}
            tput cup $((y + 1)) $((x * 2 + 1))
            echo -n "  "
        fi
        snakeParts[$bIndex]=${snakeParts[$((bIndex - 1))]}
        getCoords ${snakeParts[$bIndex]}
        tput cup $((y + 1)) $((x * 2 + 1))
        echoBody $bIndex
    done

    # Finally move head
    snakeParts[0]=c"$headX,$headY,$headDir"c
    tput cup $((headY + 1)) $((headX * 2 + 1))
    echoHead

    [ $(echo ${snakeParts[@]} | grep -Eo "c$headX,$headY," | wc -l) -ge 2 ] && endGame=2  # Self-collision check, must be latest update

    [ ${#snakeParts[@]} -eq $((size * size)) ] && endGame=1  # Win condition
}

doFood () {
    foodCoords="c$((food[0])),$((food[1])),"
    if [[ ${snakeParts[0]} =~ $foodCoords ]]; then  # Respawn food if eaten
        grow
        newFood
        drawScore
    fi
}


clear
drawFrame
drawScore
doSnake
newFood
endGame=0
until [ $endGame -ne 0 ]; do
    doFood
    tput cup $((size + 1)) $((size * 2 + 2))
    ## echo ${snakeParts[@]}
    read -sd " " -t $(echo "e(-${#snakeParts[@]} / $size ^ 2) + 0.1" | bc -l) dirs
    setDir $dirs
    doSnake
done
drawScore
drawWin $endGame