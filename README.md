# Hitori_Solver
### Author: Matt Iandoli
### Date: March 2018

## Description
A Julia script that solves a Hitori puzzle
Rules and description of the puzzle game Hitori
https://www.puzzlemix.com/rules-hitori.php?briefheader=1&JStoFront=1

## How It Works
1. Finds squares that are adjacent to each other that are the same number and then shades in any squares along the row/column of the same number
2. When a square gets shaded in, circle all adjacent squares
3. Check the circled squares along the rows and columns and shade in any equal numbers
4. Repeat back and forth of shading and circling until the call stack runs out
5. Fill in any squares that are the only in the row and column
6. Use a flooding algorithm to fill any undecided spaces

### More on the flooding algorithm
* Uses the concept of "liberties"
	* Liberty: (term used in the game "Go") a connection from a group to the rest of the grid
* Starts at a circled space and any adjacent circled square gets recursively called and any non-circled space gets counted
* After the flood runs it, it returns the number of liberties counted
* If the total count is 1, it is determined that the only liberty it was needs to be circled (otherwise it wouldn't connect to the rest of the grid)
* Repeats for all groups on the grid

## How to Run It
1. Run on the Julia Pro Command Line
2. Have the hitori.jl file in the Julia local folder
3. Type the following in the command line:
	1. ARGS = (desired puzzle, default: 177)
	2. include("hitori.jl")

