library(shiny)
library(shinythemes)
library(markdown)
library(dplyr)
library(tm)
library(shinyjs)

shinyUI(
    navbarPage(
        "WordPredict AI",
        theme = shinytheme("flatly"),
        tabPanel(
            "Predictor",
            useShinyjs(),
            fluidPage(
                tags$head(
                    tags$style(HTML("
                        .main-header {
                            background-color: #f8f9fa;
                            padding: 2rem;
                            border-radius: 10px;
                            margin-bottom: 2rem;
                        }
                        .prediction-card {
                            background-color: white;
                            padding: 1.5rem;
                            border-radius: 8px;
                            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                            margin-top: 1rem;
                        }
                        .input-section {
                            background-color: #ffffff;
                            padding: 2rem;
                            border-radius: 8px;
                            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                        }
                    "))
                ),
                
                # Header Section
                div(class = "main-header",
                    h1("Next Word Prediction", class = "text-center"),
                    p("Powered by Natural Language Processing", class = "text-center")
                ),
                
                # Main Content
                fluidRow(
                    column(8, offset = 2,
                           div(class = "input-section",
                               textAreaInput("userInput",
                                           "Enter your text:",
                                           value = "",
                                           placeholder = "Start typing here...",
                                           rows = 3,
                                           resize = "vertical"
                               ),
                               
                               # Prediction Display
                               div(class = "prediction-card",
                                   h4("Predicted Next Word"),
                                   textOutput("prediction"),
                                   hr(),
                                   p(strong("Prediction Method:")),
                                   textOutput("note"),
                                   br(),
                                   textOutput("predictionCount")
                               )
                           )
                    )
                )
            )
        ),
        
        # About Panel
        tabPanel(
            "About",
            fluidRow(
                column(8, offset = 2,
                       div(class = "about-section",
                           h2("About WordPredict AI"),
                           hr(),
                           h4("Developer Information"),
                           p("Created by: Mohamed Belmouidi"),
                           p("Last Updated: January 3, 2025"),
                           br(),
                           h4("Project Overview"),
                           p("This application is part of the Data Science Specialization 
                             Capstone Project. It uses natural language processing and 
                             machine learning techniques to predict the next word in a 
                             sentence based on the previous words entered."),
                           br(),
                           h4("How it Works"),
                           p("The application uses a sophisticated n-gram model trained 
                             on a large corpus of text data. It analyzes patterns in 
                             language to make intelligent predictions about what word 
                             might come next in your sentence."),
                           br(),
                           h4("Links"),
                           p(HTML(paste(
                               "Source code available on ", 
                               a(href = "https://github.com/Mohamed-BELMOUIDI/capstone_app",
                                 "GitHub", target = "_blank")
                           )))
                       )
                )
            )
        )
    )
)
