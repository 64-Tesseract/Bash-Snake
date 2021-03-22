#!/bin/bash

IFS="%"
cd "${0%/*}"
stty -echo

declare -A optionVals
optionVals=([2]=8 [1]=0 [0]=0)
declare -A options
options=([2,name]="Size"        [2,min]=6   [2,max]=16
         [1,name]="Snake Style" [1,min]=0   [1,max]=3
         [0,name]="Loop"        [0,min]=0   [0,max]=1
         )
optionCount=$((${#options[@]} / 3))
selOption=$(($optionCount - 1))


while [ 1 ]; do
    clear

    echo "██  ▄▀▄ ▄█▀ █ █ ▒▒▓▓"
    echo "█▄▀ █▀█ ▄▄▀ █▀█ ░░██"
    echo "  ▄▄ ▄▄   ▄  ▄ ▄ ▄▄▄"
    echo " ▀▀▄ █ █ █▄█ █▄▀ █▀"
    echo " ▀▀  ▀ ▀ ▀ ▀ ▀ ▀ ▀▀▀"

    for (( option=$((optionCount - 1)); option >= 0 ; option-- )); do
            name=${options["$option,name"]}
            val=${optionVals[$option]}
            [ $option -eq $selOption ] && echo -n "> " || echo -n "  "
            echo -n $name
            spaces=$((16 - ${#name} - ${#val}))
            for (( space=0; space < $spaces; space++ )); do echo -n " "; done
            echo -n $val
            [ $option -eq $selOption ] && echo " <" || echo
    done
    
    echo
    echo "   W/A/S/D to move"
    echo "   Space to start!"
    
    read -sn 1 input
    case $input in
        "w")
            selOption=$((selOption + 1))
            ;;
        "s")
            selOption=$((selOption - 1))
            ;;
        "a")
            optionVals[$selOption]=$((${optionVals[$selOption]} - 1))
            [ ${optionVals[$selOption]} -lt ${options["$selOption,min"]} ] && optionVals[$selOption]=${options["$selOption,min"]}
            ;;
        "d")
            optionVals[$selOption]=$((${optionVals[$selOption]} + 1))
            [ ${optionVals[$selOption]} -gt ${options["$selOption,max"]} ] && optionVals[$selOption]=${options["$selOption,max"]}
            ;;
        " ")
            break
            ;;
    esac
    [ $selOption -lt 0 ] && selOption=$((optionCount - 1)) || selOption=$((selOption % $optionCount))
done

./snake.sh ${optionVals[@]}