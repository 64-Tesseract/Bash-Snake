# Bash-Snake

Simple terminal-based Snake made purely in Bash. Use W/A/S/D to move and Space to skip forward.  
The game may slow down as you progress, probably due to inefficiencies with associative arrays.

You may run `snake_menu.sh` for a simple options screen, or run `snake.sh [size [style [loop]]]` directly.  
`size` determines the size of the board, and works best at values between 6 and 16.  
`style` is the rendering of the snake; `0` is simple gradient, `1` is simple striped, and `2` & `3` are respective fancy versions with custom head/tail renderings.  
`loop` determines if the walls are solid and kill when eaten (`0`), or if the world loops around on itself (`1`).


If you Ctrl-C out of the menu or game, you *may* need to run `stty echo` to reenable input feedback in your terminal session.
