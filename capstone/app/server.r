### Next Word Prediction Application
### Author: Mohamed Belmouidi
### Date: January 3, 2025

# Loading n-grams
bigram <- readRDS("data/bigram.RData")
trigram <- readRDS("data/trigram.RData")
quadgram <- readRDS("data/quadgram.RData")
note <- ""

matching <- function(input) {
    # Cleaning the input
    input <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", input, perl = TRUE, ignore.case = FALSE)  
    input <- gsub("@[^\\s]+", "", input, perl = TRUE, ignore.case = FALSE)
    input <- removeNumbers(removePunctuation(tolower(input)))
    input <- strsplit(input, " ")[[1]]
    
    # More than 2 words as input
    if (length(input) > 2) {
        input <- tail(input, 3)
        if (identical(character(0), head(quadgram[quadgram$unigram == input[1] & 
                                                quadgram$bigram == input[2] & 
                                                quadgram$trigram == input[3], 4], 1))) {
            matching(paste(input[2], input[3], sep=" "))
        } else {
            note <<- "Prediction based on last three words"; 
            head(quadgram[quadgram$unigram == input[1] & 
                         quadgram$bigram == input[2] & 
                         quadgram$trigram == input[3], 4], 1)
        }
    }
    # Two words as input
    else if (length(input) == 2) {
        input <- tail(input, 2)
        if (identical(character(0), head(trigram[trigram$unigram == input[1] & 
                                               trigram$bigram == input[2], 3], 1))) {
            matching(input[2])
        } else {
            note <<- "Prediction based on last two words"; 
            head(trigram[trigram$unigram == input[1] & 
                        trigram$bigram == input[2], 3], 1)
        }
    }
    # One word as input
    else if (length(input) == 1) {
        input <- tail(input, 1)
        if (identical(character(0), head(bigram[bigram$unigram == input[1], 2], 1))) {
            note <<- "No prediction available - suggesting common word"; 
            head("the", 1)
        } else {
            note <<- "Prediction based on last word"; 
            head(bigram[bigram$unigram == input[1], 2], 1)
        }
    }
}

shinyServer(function(input, output, session) {
    # Reactive values for tracking prediction state
    values <- reactiveValues(
        lastInput = "",
        lastPrediction = "",
        predictionCount = 0
    )
    
    # Update prediction when input changes
    observeEvent(input$userInput, {
        req(input$userInput)
        if (input$userInput != values$lastInput) {
            result <- matching(input$userInput)
            values$lastPrediction <- result
            values$lastInput <- input$userInput
            values$predictionCount <- values$predictionCount + 1
        }
    })
    
    # Render user input
    output$userSentence <- renderText({
        input$userInput
    })
    
    # Render prediction
    output$prediction <- renderText({
        values$lastPrediction
    })
    
    # Render prediction note
    output$note <- renderText({
        note
    })
    
    # Render prediction count
    output$predictionCount <- renderText({
        paste("Total predictions made:", values$predictionCount)
    })
})
