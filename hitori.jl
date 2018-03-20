# Hitori_Solver
# @author Matthew Iandoli
# @date March 2018

# Prints the given puzzle in a format that is easy to understand
# @param puzzle Array of ints that represent the given puzzle
# @param solve Array of characters that represent the solved portion of the puzzle
# @param highX Int for the x-index to be highlighted (Default: 0 or none highlighted)
# @param highY Int for the y-index to be highlighted
# @return void
function printpuzzle(puzzle, solve, highX = 0, highY = 0)
    # Loops thru each element in the puzzle array
    for i = 1:size(puzzle, 1)
        for j = 1:size(puzzle, 2)
            curr = puzzle[i, j]
            space = curr < 10 ? "    " : "   " # Correct spacing
            # Prints out specific colors on if each element is solved
            if solve[i, j] == "○" # Green: circled
                if i == highX && j == highY
                    print_with_color(:blue, curr, space) # Blue: highlighted
                else
                    print_with_color(:green, curr, space)
                end
            elseif solve[i, j] == "■" # Red: shaded in
                if i == highX && j == highY
                    print_with_color(:blue, curr, space)
                else
                    bold = true;
                    print_with_color(:red, curr, space)
                end
            else # Black: unsolved
                if i == highX && j == highY
                    print_with_color(:blue, curr, space)
                else
                    print(curr, space)
                end
            end
        end
        print("\n\n")
    end
end

# Solves the puzzle
# @param puzzle Array of ints representing the hitori grid
# @return void
function solve(puzzle)
    # Creates an array of characters that represent an unsolved state
    solution = fill("□", size(puzzle, 1), size(puzzle, 2))

    # "Circles" the number at the index and then checks its row and column for equal numbers
    # @param x Int for the row index
    # @param y Int for the column index
    # @return void
    function circle(x, y)
        # Circle the square
        solution[x, y] = "○"
        curr = puzzle[x, y]

        # Checks down the column
        for i = 1:size(puzzle, 1)
            val = puzzle[i, y]
            state = solution[i, y]
            if state == "□" && i != x && val == curr
                shade(i, y) # Mutually recursively calls shade function
            end
        end

        # Checks along the row
        for j = 1:size(puzzle, 2)
            val = puzzle[x, j]
            state = solution[x, j]
            if state == "□" && j != y && val == curr
                shade(x, j)
            end
        end
    end

    # "Shades" in the square on the puzzle with the given index
    # @param x Int for the row index
    # @param y Int for the column index
    # @return void
    function shade(x, y)
        # Fill in square
        solution[x, y] = "■"

        # Circle adjacents
        for i = (x - 1):(x + 1)
            if i > 0 && i <= size(puzzle, 1) &&  i != x && solution[i, y] == "□"
                circle(i, y) # Mutually recursively calls circle function
            end
        end
        for j = (y - 1):(y + 1)
            if j > 0 && j <= size(puzzle, 2) && j != y && solution[x, j] == "□"
                circle(x, j)
            end
        end
    end

    # Loops thru the puzzle and circle any squares that don't have a duplicate in its row and column
    # @param void
    # @return void
    function singles()
        # Goes thru all the rows
        for i = 1:size(puzzle, 1)
            # Goes thru each column in the row and checks if its the only one
            for j = 1:size(puzzle, 2)
                single = true
                curr = puzzle[i, j]
                if solution[i, j] == "□"
                    # Checks along the column
                    for k = 1:size(puzzle, 1)
                        state = solution[k, j]
                        val = puzzle[k, j]
                        # Checks:   not itself
                        #           not filled in
                        #           same value
                        if k != i && state != "■" && val == curr
                            single = false
                            break
                        end
                    end

                    # Checks to see if it is still single
                    if single
                        # Checks along the row
                        for k = 1:size(puzzle, 2)
                            val = puzzle[i, k]
                            state = solution[i, k]
                            if k != j && state != "■" && val == curr
                                sinlge = false
                                break
                            end
                        end
                    end

                    # Checks if it is the only one in the row and column
                    if single
                        circle(i, j)
                    end
                end

            end
        end
    end

    # "Floods" the puzzle: checks to see if any groups have one liberty and if so circles it
    # @param void
    # @return Boolean if there was anything circled
    function flooding()
        changed = false;
        # Logs the history of whats been checked
        history = fill(0, size(puzzle, 1), size(puzzle, 2))

        # Counts the liberties of the group the given element is in
        # @param x Int for the row index
        # @param y Int for the column index
        # @return Int the number of liberties
        function countLiberties(x, y)
            history[x, y] = 1 # Updates its state so we don't double count

            # Checks if the square is liberty to the group
            # @param x Int for the row index
            # @param y Int for the column index
            # @return Int the number of liberties at that square
            function isLiberty(i, j)
                if history[i, j] == "0"
                    if puzzle[i, j] == "○"
                        return countLiberties(i, j) # mut. rec.
                    elseif puzzle[i, j] == "□"
                        return 1
                    else
                        return 0
                    end
                end
            end

            # Starts the flooding algorithm by checking around the square and then calling a mutually recursive function
            libCount = 0
            for i = (x - 1):(x + 1)
                if i > 0 && i <= size(puzzle, 1)
                    libCount += isLiberty(i, y) # mut. rec.
                end
            end
            for j = (y - 1):(y + 1)
                if j > 0 && j <= size(puzzle, 2)
                    libCount += isLiberty(x, j) # mut. rec.
                end
            end
            return libCount
        end

        # Array to keep track of what has been circled
        circling = fill(0, size(puzzle, 1), size(puzzle, 2))

        # Circles a group that has been counted with one liberty
        # @param x Int for the row index
        # @param y Int for the column index
        # @return void
        function circleLiberty(x, y)
            circling[x, y] = 1
            # Starts flooding down the column
            for i = (x - 1):(x + 1)
                if i > 0 && i <= size(puzzle, 1)
                    if circling[i, y] == 0
                        if puzzle[i, y] == "○"
                            circleLiberty(i, y) # Recursively call the flooding algorithm
                        elseif puzzle[i, y] == "□"
                            circle(i, y)
                        end
                    end
                end
            end

            # Starts flooding down the row
            for j = (y - 1):(y + 1)
                if j > 0 && j <= size(puzzle, 2)
                    if circling[x, j] == 0
                        if puzzle[x, j] == "○"
                            circleLiberty(x, j) # Recursively call the flooding algorithm
                        elseif puzzle[i, y] == "□"
                            circle(x, j)
                        end
                    end
                end
            end
        end

        # Loops thru the whole puzzle checking each square's group and flooding if only one liberty
        for i = 1:size(puzzle, 1)
            for j = 1:size(puzzle, 2)
                if puzzle[i, j] == "○"
                    if countLiberties(i, j) == 1
                        changed = true # Keeps track if anything has been changed
                        circleLiberty(i, j)
                    end
                end
            end
        end
        return changed
    end

    # Checks for a pair of equal numbers adjacent to each other
    # Then "shades in" any equal number in the same row/column
    # @param void
    # @return void
    function doubles()
        # Loops thru each element in the array
        for i = 1:(size(puzzle, 1) - 1)
            for j = 1:(size(puzzle, 2) - 1)
                # Check doubles down the columns
                if puzzle[i, j] == puzzle[i + 1, j]
                    # Shade in any other occurences of the value in the column
                    for k = 1:size(puzzle, 1)
                        if solution[k, j] == "□" && k != i && k != i + 1 && puzzle[k, j] == puzzle[i, j]
                            shade(k, j)
                        end
                    end
                end

                # Check doubles along the rows
                if puzzle[i, j] == puzzle[i, j + 1]
                    # Shade in any other occurences of the value in the row
                    for k = 1:size(puzzle, 2)
                        if solution[i, k] == "□" && k != j && k != j + 1 && puzzle[i, k] == puzzle[i, j]
                            shade(i, k)
                        end
                    end
                end
            end
        end
    end

    # Calls the methods in order that solve puzzle
    doubles() # Most important method: usually solves the entire puzzle
    singles() # Not important to solving puzzle: fills in any gaps

    # Cleans up at the end of the solve for any undecided squares
    while flooding()
    end

    printpuzzle(puzzle, solution)
end

# Sets of puzzles
#152
puzzle152 = vcat([7 8 2 7 2 2 2 3],
                [4 7 5 6 8 1 3 2],
                [1 4 2 3 5 6 8 7],
                [6 6 7 4 2 7 5 8],
                [2 2 1 1 1 4 6 5],
                [2 5 3 4 6 7 3 8],
                [2 6 4 7 7 7 2 1],
                [8 3 8 2 4 5 7 5])
#161
puzzle161 = vcat([3 7 8 8 6 5 2 2],
                [8 8 5 1 6 6 2 2],
                [7 2 8 2 2 2 6 5],
                [6 2 7 3 1 8 5 2],
                [5 1 6 2 6 7 5 2],
                [5 5 5 6 4 4 8 7],
                [2 2 3 7 5 4 1 3],
                [8 4 1 1 3 3 7 6])
#177
puzzle177 = vcat([8 12 5 2 2 2 11 3 3 3],
                [6 10 7 9 4 8 1 3 5 12],
                [3 11 4 6 5 5 5 12 2 4],
                [8 6 9 8 6 10 3 5 3 2],
                [2 10 8 5 12 4 7 11 1 8],
                [5 11 6 8 8 7 12 12 4 12],
                [8 9 2 11 11 11 8 10 10 7],
                [7 5 8 10 5 9 2 5 6 1],
                [12 8 1 3 11 2 7 9 11 7],
                [10 6 11 8 8 12 7 7 7 4],
                [11 1 12 2 8 1 6 8 10 5],
                [7 5 10 12 7 2 4 10 8 4])
#193
puzzle193 = vcat([3 4 12 11 13 6 13 14 5 5 2 1],
                [9 3 11 12 12 12 14 13 1 6 1 14],
                [11 9 5 4 4 14 10 7 13 15 14 9],
                [15 1 9 6 10 3 12 4 2 12 14 13],
                [2 5 13 12 3 7 1 15 6 8 14 2],
                [6 4 15 4 1 1 3 4 8 12 5 4],
                [12 13 6 5 7 15 9 8 9 1 11 14],
                [7 5 1 15 2 10 5 3 9 7 6 5],
                [13 15 8 11 9 6 11 10 9 3 13 12],
                [5 3 14 13 12 8 14 1 7 9 5 3],
                [10 11 11 3 5 13 7 12 12 13 9 9],
                [14 2 10 9 11 9 13 12 12 5 15 14],
                [9 10 3 6 4 12 14 5 11 6 8 9],
                [13 11 7 6 8 1 10 6 15 2 12 11],
                [7 9 2 6 3 7 5 4 2 12 7 2])
#194
puzzle194 = vcat([6 4 8 5 15 7 2 13 10 12 11 4],
                [6 11 15 10 7 13 1 3 2 4 12 13],
                [6 5 5 6 1 8 10 14 7 13 12 7],
                [2 6 11 7 3 9 12 1 13 15 12 9],
                [8 13 2 14 9 1 11 7 4 14 5 13],
                [3 10 12 7 4 3 13 2 12 1 15 10],
                [10 15 4 1 12 3 5 10 6 8 15 2],
                [13 10 7 10 14 3 8 12 9 4 10 13],
                [1 14 1 15 10 2 4 8 5 7 6 1],
                [7 12 1 7 8 12 2 13 3 7 4 14],
                [5 15 14 11 7 13 1 4 8 3 2 5],
                [4 2 6 5 13 5 7 11 8 10 11 4],
                [4 9 5 10 7 12 14 3 8 2 1 11],
                [4 1 5 2 12 4 5 10 7 13 8 3],
                [1 6 5 7 8 9 11 1 12 14 13 1])
# Solve puzzle:
arg = 177 # Default puzzle
if size(ARGS, 1) == 1
    arg = ARGS[1] # User selected puzzle to solve
end

# Print out puzzle name
println("Puzzle ", arg, "\n")
puzzle = puzzle177
if arg == 152
    puzzle = puzzle152
elseif arg == 161
    puzzle = puzzle161
elseif arg == 177
    puzzle = puzzle177
elseif arg == 193
    puzzle = puzzle193
elseif arg == 194
    puzzle = puzzle194
end

# Call function to solve puzzle
solve(puzzle)
