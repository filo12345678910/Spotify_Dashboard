library(shiny)
library(shinydashboard)
library(spotifyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

header <- dashboardHeader(
  title = "Spotify Dashboard"
)

sidebar <- dashboardSidebar(
  
)

body <- dashboardBody(
  box(
    title = "Artist's songs",
    textInput("artist.name", "Artist's name:", value = ""),
    actionButton("generate_btn", "Generate Graph"),
    plotlyOutput("graph1")
  ),
  box(
    title = "Artist's discography",
    verbatimTextOutput("text1")
  ),
  box(
    title = "Songs characteristcs",
    DT::dataTableOutput("table1")
  ),
  box(
    title = "Popular playlists",
    selectInput("graph2_input", "Select Country:", choices = read.csv("country_codes.csv", sep = ";")$Country),
    uiOutput("graph2")
  )
)

ui <- dashboardPage(
  header,
  sidebar,
  body
)