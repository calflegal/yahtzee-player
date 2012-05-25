Info
--------

This was a project for a class...

It is not fully object oriented (no class definitions) as this was not the assignment.

When placed in a directory and executed it should play a game of yahtzee using the dice rolls contained in all files with a .rolls extension. 

Note: your program MUST play "honestly", i.e. by only looking at the dice rolls in sequence as they would occur in a live-action game.

This file is a set of 15 dice (in order) for 13 turns of the game.

Your program should indicate the result of play by generating a .yahtzee file for each .rolls file.

The .yahtzee file format is as follows:

the 5 dice chosen ; the indices of these dice; category score

Example:

5 5 5 2 2 ; 3 8 9 10 11; house 25

The last line of the .yahtzee file should be the total score as follows:
Example:

Score: 256