#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(data.table)
library(ggplot2)
data <- unique(fread("data/radius_score.csv")[, goslim := NULL])
data <- data[!is.na(uniqueness)]
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  data$angle <- runif(n = nrow(data), min = 0, max = 2*pi)
  plot_data <- eventReactive(input$beta,{
    if(input$beta >0){
      alpha <- input$beta + 1
      beta <- 1
    }else if(input$beta < 0){
      alpha <- 1
      beta <- input$beta * (-1) + 1
    }else{
      alpha <- 1
      beta <- 1
    }
    data$radius <- pbeta(q = 1 - data$uniqueness, shape1 = alpha, shape2 = beta)
    return(data)
  })


  output$distPlot <- renderPlot({
    ggplot(plot_data(), aes(x = angle, y = radius, size = 1 - radius)) +
      geom_point(color = "white") +
      coord_polar() +
      geom_hline(yintercept = 0.5, color = "grey", alpha = 0.4) +
      scale_y_continuous(limits = c(0,1)) +
      theme(axis.line=element_blank(),
            axis.text.x=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            legend.position="none",
            panel.background=element_blank(),
            panel.border=element_blank(),
            panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),
            plot.background = element_rect(fill = "black"))
    # generate bins based on input$bins from ui.R
    # x    <- faithful[, 2]
    # bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    # hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })

})
