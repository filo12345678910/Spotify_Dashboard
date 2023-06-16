library(shiny)
library(shinydashboard)
library(spotifyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(fmsb)

Sys.setenv(SPOTIFY_CLIENT_ID = '459c2a8ce83c4d5b8692cd08b60d8cd6')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '0ac29b401c5947119d7efe12302363a3')

showcase.data = get_artist_audio_features("Kendrick Lamar")

createNiceTable <- function(data) {
  datatable(
    data,
    options = list(
      dom = 'Bfrtip',
      lengthChange = FALSE,
      buttons = c('copy', 'csv', 'excel'),
      paging = TRUE,
      searching = TRUE,
      ordering = TRUE,
      autoWidth = F,
      filter = 'top',
      columnDefs = list(list(width = '25%', targets = 1))
    ),
    class = 'display',
    extensions = 'Buttons'
  )
}


drawRadarPlot <- function(df, selectedAlbum, selectedTrack) {
  # Filter the dataframe based on the selected album and track
  filtered_df <- df[df$album_name == selectedAlbum & df$track_name == selectedTrack, ] %>%
    select(liveness, energy, instrumentalness, danceability, speechiness, valence)
  
  values <- unlist(filtered_df[1, ])
  
  # Define the categories (theta) corresponding to each value
  categories <- c('liveness', 'energy', 'instrumentalness', 'danceability', 'speechiness', 'valence')
  
  # Create the plotly figure for the radar chart
  fig <- plot_ly(
    type = 'scatterpolar',
    r = values,
    theta = categories,
    fill = 'toself'
  )
  
  # Customize the layout of the radar plot
  fig <- fig %>%
    layout(
      polar = list(
        radialaxis = list(
          visible = TRUE,
          range = c(0,1)
        )
      ),
      showlegend = FALSE
    )
  fig
}

function(input, output, session){
  
  real.cached.artist <- reactive({
    if(!is.null(input$artist.name) && nchar(trimws(input$artist.name)) > 0) {
      return(get_artist_audio_features(input$artist.name))
    }
    return(showcase.data)
  })
  
  start.year <- reactive({
    input$start_year
  })
  
  last.year <- reactive({
    input$last_year
  })
  
  cached.artist <- reactive({
    real.cached.artist() %>%
      filter(album_release_year >= start.year() & album_release_year <= last.year())
  })

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
  
  observeEvent(input$artist.name, {
    album_names <- cached.artist() %>% 
      select(album_name)
    
    # Update the choices of the selectInput widget with the album names
    updateSelectInput(session, "selected.album", choices = album_names)
  })
  
  observeEvent(input$selected.album, {
    tracks <- cached.artist() %>% 
      filter(album_name == input$selected.album) %>%
      select(track_name)
    
    # Update the choices of the selectInput widget with the album names
    updateSelectInput(session, "selected.track", choices = tracks)
  })
  
  observeEvent(input$artist.name, {
    start <- min(cached.artist()$album_release_year)
    
    # Update the choices of the selectInput widget with the album names
    updateSliderInput(session, "start_year", min = start, value = start)
    updateSliderInput(session, "last_year", min = start, value = 2023)
  })
  
  output$graph3 <- renderPlotly({
    drawRadarPlot(cached.artist(), input$selected.album, input$selected.track)
  })

  
  output$table1 <- DT::renderDataTable({
    df <- cached.artist() %>%
      select(c("album_name", "danceability", "energy", "tempo")) %>%
      rename(album = album_name) %>%
      aggregate(. ~ album, FUN = mean) %>% 
      mutate_if(is.numeric, ~ round(., 2))
    
    createNiceTable(df)
  })
  
  output$histogram <- renderPlotly({
    p <- cached.artist() %>%
      filter(album_release_year >= start.year() & album_release_year <= last.year()) %>%
      mutate(date = as.Date(album_release_date)) %>%
      rename(album = album_name) %>%
      ggplot(aes(x = date, fill = album)) +
      geom_histogram() +
      labs(title = "Histogram of Song Releases",
           x = "Year",
           y = "Count")
    ggplotly(p)
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