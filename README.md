# Chess
Final Ruby project from TOP

Specification from [The Odin Project](https://www.theodinproject.com/lessons/ruby-ruby-final-project)

# First attempt at planning

## The idea as of now

1. Do it the TDD way.
2. Update README regularly and ahead of doing things so I can document the journey better.
3. Find the easiest problem to solve and make it the starting point.
4. A promising starting point is the pieces with the pawn, bishop and rook.
5. Maybe something like `a1.up` returning `a2` and `a1.left` returning `nil` used to move things around? Seems like pawns need colour-specific move rules.
6. The pieces should hold their colour and position as instance variables.
7. At first I should not worry about piece collision, the board is necessary for pieces to become aware of that.
8. After all movement is figured out I can start involving the board.
9. The board is probably going to be made out of an array of Square objects that let me store coordinates and what they're occupied by if applicable.
10. Not sure if I need to store all pieces of a player in an instance variable. This is how I imagine the message flow to look like:

    a) PLAYER INPUT = `start_position` `end_position`,

    b) check whether the piece at `start_position` is owned by the player,

    c) check whether the move is legal,

    d) make the move,

    e) check if it is a pawn at the opposite end of the board and act accordingly,

    f) check for checks, check-mates and ties,

    g) pass turn.

    So it seems like no need for the board to hold the pieces in a separate variable from the Square board itself.

    Make note of f), the tie-checking means I have to store the history of moves somehow. This should be as easy as throwing them into an array.

11. This is probably the moment to figure some basic display going. Make it a separate class.
12. I might want to include some possible move highlighting for better UX.
13. Only at this point I'd really worry about Player creation and the entire game loop.
14. As for serialization, the Game class should be the one to be serialized - all we need is the info who's playing, whose turn it is and what is the board state.
15. This means I'd include some Driver class or script to make this easy, just like in Connect Four or Hangman.
16. Spice up the display.
17. Do the same with the README.
18. Rejoice!
