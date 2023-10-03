proc getMoveFromPlayer {} {
    set valid 0

    while {!$valid} {
        set valid 1
        puts -nonewline "\nEnter your move (row then column) e.g. 1, 3: "
        flush stdout
        set moveInput [gets stdin]
        
        set inputLength [string length $moveInput]
        
        set firstCoord -1
        set secondCoord -1
        set nextCoord -1
        
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
        
        if {$secondCoord == -1} {
            set valid 0
            puts "\ninvalid input\n"
        }
    }
    return [list [expr {$firstCoord-1}] [expr {$secondCoord-1}]]
}

proc checkGameOver {board lastMoveMarker} {
    set win 0

    if {[lindex $board 1 1] == $lastMoveMarker} {
        if {[lindex $board 0 0] == $lastMoveMarker && [lindex $board 2 2] == $lastMoveMarker} {
            set win 1
        } elseif {[lindex $board 0 2] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker} {
            set win 1
        } elseif {[lindex $board 0 1] == $lastMoveMarker && [lindex $board 2 1] == $lastMoveMarker} {
            set win 1
        } elseif {[lindex $board 1 0] == $lastMoveMarker && [lindex $board 1 2] == $lastMoveMarker} {
            set win 1
        }
    } else {
        if {[lindex $board 0 0] == $lastMoveMarker} {
            if {[lindex $board 0 1] == $lastMoveMarker && [lindex $board 0 2] == $lastMoveMarker} {
                set win 1
            } elseif {[lindex $board 1 0] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker} {
                set win 1
            }
        } elseif {[lindex $board 2 2] == $lastMoveMarker} {
            if {[lindex $board 2 1] == $lastMoveMarker && [lindex $board 2 0] == $lastMoveMarker} {
                set win 1
            } elseif {[lindex $board 1 2] == $lastMoveMarker && [lindex $board 0 2] == $lastMoveMarker} {
                set win 1
            }
        }
    }

    if {$win} {
        return [expr {$lastMoveMarker == 1 ? 10 : -10}]
    }

    set draw 1 
    for {set i 0} {$i < 3} {incr i} {
        set row [lindex $board $i]
        for {set j 0} {$j < 3} {incr j} {
            set current_value [lindex $row $j]
            # puts "Checking value at index $i,$j: $current_value"
            if {$current_value == 0} {
                # puts "setting draw to 0"
                set draw 0
                break
            }
        }
        if {!$draw} {
            break
        }
    }

    # puts "draw is... $draw"
    return [expr {$draw ? -1 : 0}]
}

proc getMinimaxMove {board playerNext maxDepth} {

    set score [checkGameOver $board [expr {$playerNext ? 2 : 1}]]

    # puts "Score is $score"

    # Recursive base case
    if {$score != 0 || $maxDepth == 0} {
        return $score
    }

    set bestScore [expr {$playerNext ? -9999 : 9999}]
    set bestRow -1
    set bestColumn -1

    for {set i 0} {$i < 3} {incr i} {
        for {set j 0} {$j < 3} {incr j} {
            if {[lindex $board $i $j] == 0} {
                lset board $i $j [expr $playerNext ? 1 : 2]
                set newResult [getMinimaxMove $board [expr {!$playerNext}] [expr {$maxDepth - 1}]]
                set newScore [lindex $newResult 0]
                lset board $i $j 0

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

    return [list $bestScore $bestRow $bestColumn]
}


proc getMoveFromAI {board playerNextInput} {
    upvar $playerNextInput playerNext

    set maxDepth 10

    set result [getMinimaxMove $board $playerNextInput $maxDepth]

    # puts "Debug: result = $result"  ;# Debugging line
    # puts "Debug: result 0 = [lindex $result 0]"  ;# Debugging line
    # puts "Debug: result 1 = [lindex $result 1]"  ;# Debugging line

    return [list [lindex $result 1] [lindex $result 2]]
}

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

set playerFirst 0

set playerChar "X"
set AIChar "O"

proc runGame {} {
    # Game start
    set gameOver 0
    set board {{0 0 0} {0 0 0} {0 0 0}}
    set gameRunning 1
    set firstValid 0
    set playerNext 0
    global playerFirst
    global playerChar
    global AIChar

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

    set playerFirst $playerNext
    
    if {$playerFirst} {
        set playerChar "X"
        set AIChar "O"
    } else {
        set playerChar "O"
        set AIChar "X"
    }

    while {!$gameOver} {
        getMove board playerNext gameOver
    }

    printBoard $board

    if {$gameOver == -1} {
        puts "It's a draw!"
    } elseif {$gameOver == -10} {
        puts "The AI wins!"
    } else {
        puts "You win!"
    }
}

runGame