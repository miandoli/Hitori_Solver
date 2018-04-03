# Hitori_Solver
# @author Matthew Iandoli
# @date March 2018

# Prints the given puzzle in a format that is easy to understand
# @param puzzle Array of ints that represent the given puzzle
# @param solve Array of characters that represent the solved portion of the puzzle
# @param col String "y" to print with color, "n" no color
# @param highX Int for the x-index to be highlighted (Purpuse: Debugging, Default: 0 or none highlighted)
# @param highY Int for the y-index to be highlighted
# @return void
function printpuzzle(puzzle, solve, col, highX = 0, highY = 0)
    # Loops thru each element in the puzzle array
    for i = 1:size(puzzle, 1)
        for j = 1:size(puzzle, 2)
            curr = puzzle[i, j]
            space = curr < 10 ? "    " : "   " # Correct spacing
            # Prints out specific colors on if each element is solved
            if solve[i, j] == "○" # Green: circled
                if i == highX && j == highY
                    print_with_color(:blue, curr, space) # Blue: highlighted
                elseif col == "y"
                    print_with_color(:green, curr, space)
                else
                    space = space == "    " ? "   " : "  "
                    print(curr, "*", space)
                end
            elseif solve[i, j] == "■" # Red: shaded in
                if i == highX && j == highY
                    print_with_color(:blue, curr, space)
                elseif col == "y"
                    bold = true
                    print_with_color(:red, curr, space)
                else
                    print(curr, space)
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
# @param haveColor String "y" to print with color, "n" no color
# @return void
function solve(puzzle, haveColor)
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

    printpuzzle(puzzle, solution, haveColor)
end

# Read and solve puzzle:
arg = "152.txt"
printColor = "n"
if size(ARGS, 1) >= 1
    arg = ARGS[1] # User selected puzzle to solve
end
if size(ARGS, 1) == 2
    printColor = ARGS[2]
end

path = abspath(string("Hitori_Solver\\Puzzles\\", arg))
print(path)
try
    # Try to read input file as an array of strings (each on line)
    myStream = open(path)
    println("File opened")
    lines = readlines(myStream)

    println("Puzzle: ", arg, "\n")

    # Get number of rows and columns
    rows = size(lines, 1)
    spaces = 0
    for char in lines[1]
        if char == ' '
            spaces += 1
        end
    end
    cols = spaces + 1

    # Parse text file
    parsePuzzle = fill(0, rows, cols)
    for i = 1:size(lines, 1)
        j = 1
        for char in lines[i]
            arr = split(lines[i], " ")
            for j = 1:size(arr, 1)
                parsePuzzle[i, j] = parse(Int, arr[j])
            end
        end
    end

    # Call function to solve puzzle
    solve(parsePuzzle, printColor)
catch
    println("Invalid file")
end
