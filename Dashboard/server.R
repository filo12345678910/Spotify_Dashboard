library(shiny)
library(shinydashboard)
library(spotifyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)

Sys.setenv(SPOTIFY_CLIENT_ID = '459c2a8ce83c4d5b8692cd08b60d8cd6')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '0ac29b401c5947119d7efe12302363a3')

function(input, output, session){
  generate_graph <- eventReactive(input$generate_btn, {
    graph1_output <- input$graph1_input
    df <- get_artist_audio_features(graph1_output)
    df %>%
      select(c("track_name", "track_href", "liveness", "energy", "loudness")) %>%
      ggplot(aes(x = liveness, y = energy, color = loudness, text = track_name)) +
      geom_point()
  })
  
  output$graph1 <- renderPlotly({
    generate_graph()
  })
}