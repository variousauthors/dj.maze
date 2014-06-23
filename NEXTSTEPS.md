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
[x] Don't show the path in multiplayer until then end

[x] Deadly game mode, in which you brighten the path you take,
    so that there is an element of urgency. A player can't just trace
    her opponent.
[x] Add a menu to use dynamic mode
[ ] options to setup the controls
    - the idea I had was, go into a mini game mode where the player must
      follow a yellow line across a maze. Whatever keys the player uses
      to run the maze, those become their controls. Maybe later, eh?
    - for now provide a config file
[x] consider moving the player2 tag to the player2 starting place (top left)
    - this means the player will see their label abobve their starting location
[x] the victory in multiplayer should be "YELLOW WINS" vs "GREEN WINS" instead of P1 P2

[ ] clever music
[ ] better sprites
[ ] add the secret victory (achievement) for players who actually WIN vs AI
[ ] Add tug-o-war style score long-term board

BUG
[x] If the player backtracks and then shadows the opponent for the rest of the
    game, they can win. This should be impossible: why isn't my AI backtracking?
[x] The player that gets there first should be frozen, and the AI should then
    move on a beat

TIM
[ ] consider making it the "redest path" rather than the darkest path
    or choose one of R G B to be the "bad" colour. This could be like
    "hard mode"
    - you could also choose having both R and G, where R is bad, or
      all three, or just one. Combinatorics!
[ ] A mode where, if you make a bunch of perfect moves you get a power
    up that lets you attack the other player somehow.
    - or improve your powers. Like a score multiplier.
[ ] in polychrome mode, the players should be black and white
