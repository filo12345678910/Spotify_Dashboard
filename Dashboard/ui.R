library(shiny)
library(shinydashboard)
library(spotifyr)
Sys.setenv(SPOTIFY_CLIENT_ID = '459c2a8ce83c4d5b8692cd08b60d8cd6')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '0ac29b401c5947119d7efe12302363a3')

header <- dashboardHeader(
  title = "Spotify Dashboard"
)

sidebar <- dashboardSidebar(
  
)

body <- dashboardBody(
  
)

ui <- dashboardPage(
  header,
  sidebar,
  body
)