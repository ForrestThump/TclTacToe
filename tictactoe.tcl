# Declare global variables
set playerFirst 0
set playerChar "X"
set AIChar "O"
set difficulty 3

# Get a tic tac toe move from the player
proc getMoveFromPlayer {} {
    set valid 0

    # Keep asking until a valid input is provided
    while {!$valid} {
        set valid 1
        puts -nonewline "\nEnter your move (row then column) e.g. 1, 3: "
        flush stdout
        set moveInput [gets stdin]
        
        set inputLength [string length $moveInput]
        
        set firstCoord -1
        set secondCoord -1
        set nextCoord -1
        
        # Parse input string until two ints in range are found
        for {set i 0} {$i < $inputLength} {incr i} {
            set currentChar [string index $moveInput $i]
            if {[string is integer -strict $currentChar]} {
                if {$currentChar > 0 && $currentChar < 4} {
                    set nextCoord $currentChar
                }
            }
            if {$nextCoord != -1} {
                if {$firstCoord == -1} {
                    set firstCoord $nextCoord
                } else {
                    set secondCoord $nextCoord
                }
                set nextCoord -1
            }
            if {$secondCoord != -1} {
                break
            }
        }
        
        # Could not find two valid ints. Try again.
        if {$secondCoord == -1} {
            set valid 0
            puts "\ninvalid input\n"
        }
    }
    return [list [expr {$firstCoord-1}] [expr {$secondCoord-1}]]
}

# # Determine if the game has ended. The if statements 
# # are more efficient than loops.
# proc checkGameOver {board lastMoveMarker} {
#     set win 0

#     # Check center square
#     if {[lindex $board 1 1] == $lastMoveMarker} {
#         if {[lindex $board 0 0] == $lastMoveMarker && [lindex $board 2 2] == $lastMoveMarker} {
#             set win 1
#         } elseif {[lindex $board 0 2] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker} {
#             set win 1
#         } elseif {[lindex $board 0 1] == $lastMoveMarker && [lindex $board 2 1] == $lastMoveMarker} {
#             set win 1
#         } elseif {[lindex $board 1 0] == $lastMoveMarker && [lindex $board 1 2] == $lastMoveMarker} {
#             set win 1
#         }
#     } else {
#         # Check upper left corner
#         if {[lindex $board 0 0] == $lastMoveMarker} {
#             if {[lindex $board 0 1] == $lastMoveMarker && [lindex $board 0 2] == $lastMoveMarker} {
#                 set win 1
#             } elseif {[lindex $board 1 0] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker} {
#                 set win 1
#             }
#             # Check lower right corner
#         } elseif {[lindex $board 2 2] == $lastMoveMarker} {
#             if {[lindex $board 2 1] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker} {
#                 set win 1
#             } elseif {[lindex $board 1 2] == $lastMoveMarker && [lindex $board 0 2] == $lastMoveMarker} {
#                 set win 1
#             }
#         }
#     }

#     # Return a score associated with the win
#     if {$win} {
#         return [expr {$lastMoveMarker == 1 ? 10 : -10}]
#     }

#     # Assume draw
#     set draw 1 
#     for {set i 0} {$i < 3} {incr i} {
#         set row [lindex $board $i]
#         for {set j 0} {$j < 3} {incr j} {
#             set current_value [lindex $row $j]
#             # If a square is blank, it's not a draw.
#             if {$current_value == 0} {
#                 set draw 0
#                 break
#             }
#         }
#         if {!$draw} {
#             break
#         }
#     }

#     return [expr {$draw ? -1 : 0}]
# }

proc checkGameOver {board lastMoveMarker} {
    # Check rows
    for {set i 0} {$i < 3} {incr i} {
        set row [lindex $board $i]
        if {[lindex $row 0] == $lastMoveMarker && [lindex $row 1] == $lastMoveMarker && [lindex $row 2] == $lastMoveMarker} {
            return [expr {$lastMoveMarker == 1 ? 10 : -10}]
        }
    }

    # Check columns
    for {set j 0} {$j < 3} {incr j} {
        if {[lindex $board 0 $j] == $lastMoveMarker && [lindex $board 1 $j] == $lastMoveMarker && [lindex $board 2 $j] == $lastMoveMarker} {
            return [expr {$lastMoveMarker == 1 ? 10 : -10}]
        }
    }

    # Check diagonals
    if {([lindex $board 0 0] == $lastMoveMarker && [lindex $board 1 1] == $lastMoveMarker && [lindex $board 2 2] == $lastMoveMarker) || 
        ([lindex $board 0 2] == $lastMoveMarker && [lindex $board 1 1] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker)} {
        return [expr {$lastMoveMarker == 1 ? 10 : -10}]
    }

    # Check for draw
    for {set i 0} {$i < 3} {incr i} {
        set row [lindex $board $i]
        for {set j 0} {$j < 3} {incr j} {
            if {[lindex $row $j] == 0} {
                return 0
            }
        }
    }

    # Assume draw if function hasn't returned by this point
    return -1
}


# Recursive minimax function to run all possible games
proc getMinimaxMove {board playerNext maxDepth} {

    set score [checkGameOver $board [expr {$playerNext ? 2 : 1}]]

    # Recursive base case
    if {$score != 0 || $maxDepth == 0} {
        return $score
    }

    set bestScore [expr {$playerNext ? -9999 : 9999}]
    set bestRow -1
    set bestColumn -1

    # For all rows and columns
    for {set i 0} {$i < 3} {incr i} {
        for {set j 0} {$j < 3} {incr j} {
            # If the square is empty
            if {[lindex $board $i $j] == 0} {
                # Try the square
                lset board $i $j [expr $playerNext ? 1 : 2]
                set newResult [getMinimaxMove $board [expr {!$playerNext}] [expr {$maxDepth - 1}]]
                
                # Get the final result from recursive base
                set newScore [lindex $newResult 0]
                # Revert the board
                lset board $i $j 0

                # Update the best score and move
                if {$playerNext && $newScore > $bestScore} {
                    set bestScore $newScore
                    set bestRow $i
                    set bestColumn $j
                } elseif {!$playerNext && $newScore < $bestScore} {
                    set bestScore $newScore
                    set bestRow $i
                    set bestColumn $j
                }
            }
        }
    }

    # Return the best score and associated move
    return [list $bestScore $bestRow $bestColumn]
}

# Return a random valid move
proc getRandomAIMove {board} {
    set randomNumber1 -1
    set randomNumber2 -1

    while {1} {
        set randomNumber1 [expr {int(rand() * 3)}]
        set randomNumber2 [expr {int(rand() * 3)}]
        if {[lindex $board $randomNumber1 $randomNumber2] == 0} {
            break
        }
    }
    return [list $randomNumber1 $randomNumber2]
}

# Use minimax to find a move
proc getMoveFromAI {board playerNextInput} {
    global difficulty
    upvar $playerNextInput playerNext

    set maxDepth [expr {$difficulty > 2} ? 10 : 2]

    if {$difficulty == 1} {
        return [getRandomAIMove $board]
    }

    set result [getMinimaxMove $board $playerNextInput $maxDepth]

    return [list [lindex $result 1] [lindex $result 2]]
}

# Print out the board
proc printBoard {board} {
    global playerChar
    global AIChar

    puts "  1 2 3"
    for {set i 0} {$i < 3} {incr i} {
        puts -nonewline "[expr $i + 1] "
        for {set j 0} {$j < 3} {incr j} {
            if {[lindex $board $i $j] == 1} {
                puts -nonewline "$playerChar"
            } elseif {[lindex $board $i $j] == 2} {
                puts -nonewline "$AIChar"
            } elseif {[lindex $board $i $j] == 0} {
                puts -nonewline " "
            } else {
                puts "YOU SHOULD NOT BE SEEING THIS. INVALID CHARACTER IN BOARD."
            }
            
            if {$j < 2} {
                puts -nonewline "|"
            } else {
                puts ""
            }
        }
        if {$i < 2} {
            puts " -------"
        }
    }
}

# Get move from player or AI
proc getMove {boardInput playerNextInput gameOverInput} {
    upvar $playerNextInput playerNext
    upvar $boardInput board
    upvar $gameOverInput gameOver

    printBoard $board

    if {$playerNext} {
        set moveValid 0
        while {!$moveValid} {
            set playerMove [getMoveFromPlayer]
            if {[lindex $board [lindex $playerMove 0] [lindex $playerMove 1]] == 0} {
                set moveValid 1
                lset board [lindex $playerMove 0] [lindex $playerMove 1] 1
            } else {
                puts "\ninvalid move location\n"
            }
        }        
    } else {
        puts "\nThe AI made its move!"
        set AImove [getMoveFromAI $board $playerNext]
        lset board [lindex $AImove 0] [lindex $AImove 1] 2
    }

    set gameOver [checkGameOver $board [expr {$playerNext == 1 ? 1 : 2}]]

    set playerNext [expr {!$playerNext}]
}

# Ask the player who should go first
proc setFirstPlayer {} {
    global playerFirst
    global playerChar
    global AIChar

    set playerNext 0
    set firstValid 0

    # Keep asking until a valid input is provided
    while {!$firstValid} {
        puts -nonewline "Will the player go first? (y/n) "
        flush stdout
        set input [gets stdin]
        set input [string tolower [string index $input 0]]

        if {$input == "y"} {
            set playerNext 1
            set firstValid 1
        } elseif {$input == "n"} {
            set playerNext 0
            set firstValid 1
        }
    }

    # Set the global chars
    set playerFirst $playerNext

    if {$playerFirst} {
        set playerChar "X"
        set AIChar "O"
    } else {
        set playerChar "O"
        set AIChar "X"
    }
}

# Ask the user for a difficulty
proc setDifficulty {} {
    global difficulty

    while {1} {
        puts -nonewline "Please input a number from 1-3 to set the difficulty (3 is hardest): "
        flush stdout
        set moveInput [gets stdin]

        # Check if the input is a single character
        if {[string length $moveInput] == 1} {
            # Check if the input is an integer
            if {[string is integer -strict $moveInput]} {
                # Check if the input falls within the range
                if {$moveInput > 0 && $moveInput < 4} {
                    set difficulty $moveInput
                    return
                }
            }
        }
        puts "\nInvalid input! Please enter a single-digit number between 1 and 3.\n"
    }
}

proc runGame {} {
    # Game start
    set board {{0 0 0} {0 0 0} {0 0 0}}
    
    # Ask player who should go first
    setFirstPlayer

    setDifficulty

    global playerFirst
    set playerNext $playerFirst

    # Run the game until it ends
    set gameOver 0
    while {!$gameOver} {
        getMove board playerNext gameOver
    }

    # Display the board one last time
    printBoard $board

    # Print the outcome
    if {$gameOver == -1} {
        puts "It's a draw!"
    } elseif {$gameOver == -10} {
        puts "The AI wins!"
    } else {
        puts "You win!"
    }
}

proc runScoreTest {} {
    set board {{1 2 1} {2 2 1} {2 1 1}}
    set score [checkGameOver $board "1"]

    puts "the score is: $score"
    return
}

# runScoreTest
runGame