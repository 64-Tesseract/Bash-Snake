# Bash-Snake

Simple terminal-based Snake made purely in Bash. Use W/A/S/D to move and Space to skip forward.
The game may slow down as you progress, probably due to inefficiencies with associative arrays.

You may run `snake_menu.sh` for a simple options screen, or run `snake.sh [size [style [loop]]]` directly.
If you Ctrl-C out of the menu or game, you *may* need to run `stty echo` to reenable input feedback in your terminal session.