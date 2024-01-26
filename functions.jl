
function draw(type, pointsDF)
# This function calculates a probability distribution based on past record of participation and draws a student based on the probability distribution.

    if type == "board"
        candidates = pointsDF[pointsDF.Enrolled .==1 .& pointsDF.boardOpen .== 1,:]
    end
    if type == "quick"
        candidates = pointsDF[pointsDF.Enrolled .==1 .& pointsDF.quickOpen .== 1,:]
    end

    board_weight = 3 # Defines how many time is going on the board worth as opposed to quick questions

    # Calculate record for each student (does not unclude absences)
    record = (candidates.boardN .+ candidates.boardY) * board_weight + candidates.quickN + candidates.quickY

    highest_record_plus = maximum(record) + 1

    remainders = highest_record_plus .- record

    sum_remainders = sum(remainders)

    probs = Weights(remainders / sum_remainders)

    sample(candidates.ID, probs)
end


function getInput(pointsDF, ID)
# This function prints the nickname of a drawn student and asks allows user to input feedback.
    nickname = pointsDF.Nickname[pointsDF.ID .== ID][1]
    println("========================================")
    println("New draw: ", nickname)
    println("========================================")
    println("A = Absent")
    println("Y/N = Present")

    result = uppercase(readline())

    while result ∉ ["A", "Y", "N"]
        println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
        println("Invalid input. Try again.")
        println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
        println("A = Absent")
        println("Y/N = Present")
        result = uppercase(readline())
    end
    result
end



function save(type, ID, result, pointsDF, logDF)
# Saves results following feedback
    log_entry = [now() ID type result]
    push!(logDF, log_entry)
    
    if type == "quick"
        if result == "A"
            pointsDF.quickAbsent[pointsDF.ID .== ID] = pointsDF.quickAbsent[pointsDF.ID .== ID] .+ 1
        end
        if result == "Y"
            pointsDF.quickY[pointsDF.ID .== ID] = pointsDF.quickY[pointsDF.ID .== ID] .+ 1
        end
        if result == "N"
            pointsDF.quickN[pointsDF.ID .== ID] = pointsDF.quickN[pointsDF.ID .== ID] .+ 1
        end
    end
    if type == "board"
        if result == "A"
            pointsDF.boardAbsent[pointsDF.ID .== ID] = pointsDF.boardAbsent[pointsDF.ID .== ID] .+ 1
        end
        if result == "Y"
            pointsDF.boardY[pointsDF.ID .== ID] = pointsDF.boardY[pointsDF.ID .== ID] .+ 1
        end
        if result == "N"
            pointsDF.boardN[pointsDF.ID .== ID] = pointsDF.boardN[pointsDF.ID .== ID] .+ 1
        end
    end

    CSV.write("points.csv", pointsDF)
    CSV.write("log.csv", logDF)

    println("Updated succesfully!")
end


function quick()
# Main function to be used to draw and save results for a quick question.
    type = "quick"

    logDF = DataFrame(CSV.File("log.csv"))
    pointsDF = DataFrame(CSV.File("points.csv"))
    
    ID = draw(type, pointsDF)

    result = getInput(pointsDF, ID)

    save(type, ID, result, pointsDF, logDF)
    
end

function board()
# Main function to be used to draw and save results for a board question.
    type = "board"

    logDF = DataFrame(CSV.File("log.csv"))
    pointsDF = DataFrame(CSV.File("points.csv"))
    
    ID = draw(type, pointsDF)

    result = getInput(pointsDF, ID)

    save(type, ID, result, pointsDF, logDF)


end