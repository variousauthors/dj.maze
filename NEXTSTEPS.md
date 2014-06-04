NEXTSTEPS
---------

[x] bootstrap this shit
[x] generate the map randomly
[x] generate the corresponding adjacencies
[x] test that a path exists from corner to corner
[x] mirror the map (there must be overlap between the mirrors...)
[x] use the adjacency matrix to get the shortest path to the middle
[x] implement rogue-like movement with the AI moving randomly
[x] implement collision with walls
[x] add the shortest path algorithm to the AI

[ ] stagger the AI's move a tic behind the player's
[x] victory to the fellow at the center!
[x] add the colours and striped score bar

[x] The Darkest Path! Score now depends on finding the darkest coloured path
[ ] Try to make the colour change a little more continuous
    right now the colours just go sharply from one to another,
    so there isn't a clear path. I want random, but then adjusted
    to make more sense (cause right now it is basically impossible)
    [ ] This could depend on how well the player is doing
[x] encouraging messages
[ ] local multiplayer
[ ] the dudes should leave a coloured echo trail behind them
[ ] revert the stripe bar to the old overall score mode

[x] Adjust the frequencies for the initial map. Try to make
    fewer open tiles along the center lines
[ ] start the map zoomed out, and then zoom in to the dude

[ ] add music, a countdown, and a taunt or two for losing
[ ] the dudes should pulse to the music when they move, and take turns moving
[ ] add a timer: if you take longer than 3 sec to make a move,
    your opponent moves.
    - maybe they just move every 3 sec regardless? With the music.
