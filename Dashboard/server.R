library(shiny)

shinyServer(function(input, output) {
  output$dashboard <- renderUI({
    includeHTML('Dashboard.html')
  })
})