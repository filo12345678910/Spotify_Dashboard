library(shiny)
library(shinydashboard)
library(spotifyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)

showcase.data = get_artist_audio_features("Kendrick Lamar")

Sys.setenv(SPOTIFY_CLIENT_ID = '459c2a8ce83c4d5b8692cd08b60d8cd6')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '0ac29b401c5947119d7efe12302363a3')

function(input, output, session){
  cached.artist <- reactive({
    if(!is.null(input$artist.name) && nchar(trimws(input$artist.name)) > 0) {
      return(get_artist_audio_features(input$artist.name))
    }
    return(showcase.data)
  })
  
  createNiceTable <- function(data) {
    datatable(
      data,
      options = list(
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
        paging = TRUE,
        searching = TRUE,
        ordering = TRUE,
        autoWidth = TRUE,
        filter = 'top'
      ),
      class = 'display',
      extensions = 'Buttons'
    )
  }

  output$graph1 <- renderPlotly({
    df <- cached.artist()
    artist <- df$artist_name[1]
    df %>%
      select(c("track_name", "liveness", "energy", "album_name")) %>%
      rename(Album = album_name, 'Energy'=energy, 'Liveness'=liveness) %>%
      ggplot(aes(x = Liveness, y = Energy, color = Album, text = track_name)) +
      geom_point() +
      ggtitle(paste(artist))
  })
  
  output$text1 <- renderText({
    df <- cached.artist()
    
    df[1]
    columns <- colnames(df)
    paste(columns, "\n")
  })
  
  output$table1 <- DT::renderDataTable({
    df <- cached.artist() %>%
      select(c("album_name", "danceability", "energy", "tempo", "instrumentalness")) %>%
      rename(album = album_name) %>%
      aggregate(. ~ album, FUN = mean) %>% 
      mutate_if(is.numeric, ~ round(., 2))
    
    createNiceTable(df)
  })
  
  country_codes <- read.csv("country_codes.csv", sep = ";")
  
  output$graph2 <- renderUI({
    code <- gsub("\"", "", country_codes$`Alpha.2.code`[country_codes$Country == input$graph2_input])
    code <- substr(code, 2, nchar(code))
    
    result <- tryCatch(
      {
        get_featured_playlists(country = code) %>%
          select(c("name", "id"))
      },
      error = function(e) {
        message("Unavailable country")
        return(NULL)
      }
    )
    
    if (is.null(result)) {
      return("Unavailable country")
    } else {
      playlist_links <- lapply(seq_len(nrow(result)), function(i) {
        tags$a(href = paste0("https://open.spotify.com/playlist/", result$id[i]), target = "_blank", result$name[i], br())
      })
      tagList(playlist_links)
    }
  })
}