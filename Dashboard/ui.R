library(shiny)
library(shinydashboard)
library(spotifyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)

header <- dashboardHeader(
  title = "Spotify Dashboard"
)

sidebar <- dashboardSidebar(
  
)

body <- dashboardBody(
  box(
    title = "Graph1",
    textInput("graph1_input", "Enter Text:", value = ""),
    actionButton("generate_btn", "Generate Graph"),
    plotlyOutput("graph1")
  ),
  box(
    title = "Graph2",
    selectInput("graph2_input", "Select Country:", choices = read.csv("country_codes.csv", sep = ";")$Country),
    uiOutput("graph2")
  )
)

ui <- dashboardPage(
  header,
  sidebar,
  body
)