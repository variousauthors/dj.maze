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
[x] encouraging messages
[x] victory to the fellow at the center!
[x] add the colours and striped score bar
[x] revert the stripe bar to the old overall score mode
[x] The Darkest Path! Score now depends on finding the darkest coloured path
[x] fade background to black while end game message is showing (fade map only)
[x] finite state machine!
[x] refactor! I want the FSM to be super clear, we need a game loop file
[x] local multiplayer

[x] implement the alone/together menu and title screen
[x] it should be possible to enter the game late (P2 press "return") and ("Here comes a new challenger!")
[x] the dudes should leave a coloured echo trail behind them
[x] player 1's score should be on the bottom
[x] "you win" should be replaced with "player2 wins" in multiplayer
[x] add the lumines unit
[x] implement token input for single player
[x] prepare gamejolt API
[ ] Add gamejolt API
[ ] Don't show the path in multiplayer until then end

[x] Deadly game mode, in which you brighten the path you take,
    so that there is an element of urgency. A player can't just trace
    her opponent.
[ ] Add a menu to use dynamic mode
[ ] options to setup the controls

[ ] clever music
[ ] better sprites
[ ] add the secret victory (achievement) for players who actually WIN vs AI

BUG
[x] If the player backtracks and then shadows the opponent for the rest of the
    game, they can win. This should be impossible: why isn't my AI backtracking?
