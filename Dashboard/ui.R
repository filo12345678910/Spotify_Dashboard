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
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Playlists", tabName = "playlists", icon = icon("play")),
    sliderInput(
      "start_year",
      "First Year:",
      min = 1990,
      max = 2023,
      value = 2000,
      step = 1,
      sep = '',
      ticks = F,
      co
    ),
    sliderInput(
      "last_year",
      "Last Year:",
      min = 1990,
      max = 2023,
      value = 2023,
      step = 1,
      sep = '',
      ticks = F
    )
  )
)

body <- dashboardBody(
  tabItems(
    tabItem( tabName = 'dashboard',
      fluidPage(
      box(
        title = "Artist's songs",
        textInput("artist.name", "Artist's name:", value = ""),
        plotlyOutput("graph1")
      ),
      box(
        title = "Song analysis",
        selectInput("selected.album", "Select album:", choices = NULL),
        selectInput("selected.track", "Select track:", choices = NULL),
        plotlyOutput("graph3")
      ),
      box(
        title = "Albums' info",
        DT::dataTableOutput("table1")
      ),
      box(
        title = "Activity timeline",
        plotlyOutput("histogram")
      )
    )
    ),
    tabItem(tabName = 'playlists',
      box(
        title = "Popular playlists",
        selectInput("graph2_input", "Select Country:", choices = read.csv("country_codes.csv", sep = ";")$Country),
        uiOutput("graph2")
      )
    )
  )
  
)

ui <- dashboardPage(
  header,
  sidebar,
  body,
  skin = 'green'
)