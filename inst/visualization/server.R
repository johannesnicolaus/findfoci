library(shiny)
library(tidyverse)



# plot





shinyServer(function(input, output) {
  # show the data frame
  output$contents <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    read_csv(inFile$datapath)
  }, align = "c", width = "100%")
  
  # print table dimensions
  output$tbl_dims <- renderText({ 
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    csvfile <- read_csv(inFile$datapath)
    
    paste("Number of samples:" , dim(csvfile)[1])
  })
  

# renderplot --------------------------------------------------------------

  output$heatscatterplot <- renderPlot({
    
    heatscatter <- function(data, color_scale = scale_color_viridis_c(), 
                            line_color = "#ef3b2c", 
                            line_fun = "median", 
                            jitterwidth = 0.1, 
                            x_label = "Time (min)", 
                            y_label = "log2(Foci number + 1)", 
                            title = element_blank()){
      require(tidyverse)
      require(reshape2)

      data1 <- data
      
      factor_time <- data1 %>% colnames()
      
      # transformed data
      
      
      if (input$logfunc_data == "log2_1") {
        log_transformed <- log2(data1+1)
      } else if (input$logfunc_data == "loge_1") {
        log_transformed <- log(data1+1)
      } else if (input$logfunc_data == "log10_1") {
        log_transformed <- log10(data1+1)
      } else {log_transformed <- log2(data1+1)}
      

      # perform log2(n+1) on the foci to not remove cells with 0 foci
      data_melt <- melt(log_transformed) %>%
        na.omit() %>% 
        mutate(variable_1 = variable)
      
      res <- c()
      # get density
      
      for(i in factor_time){
        variable_filter <- filter(data_melt, variable == i)
        variable_filter <- arrange(variable_filter, value)
        variable_filter$Density<- density(variable_filter$value, n=length(variable_filter$value))$y
        res <- bind_rows(res, variable_filter)  
      }
      
      
      # theme
      theme_Publication <- function(base_size=40) {
       theme_bw(base_size=base_size)+
           theme(plot.title = element_text(size = rel(1.2), hjust = 0.5),
                  text = element_text(),
                  panel.background = element_rect(colour = NA),
                  plot.background = element_rect(colour = NA),
                  panel.border = element_rect(colour = "black"),
                  axis.title = element_text(size = rel(0.8)),
                  #            axis.title.y = element_text(angle=90,vjust =2),
                  #            axis.title.x = element_text(vjust = -0.2),
                  axis.text = element_text(), 
                  #            axis.line = element_line(colour="black"),
                  axis.ticks = element_line(),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  legend.key = element_rect(colour = NA),
                  legend.position = "right",
                  legend.direction = "vertical",
                  legend.key.size= unit(1, "cm"),
                  legend.title = element_text(size = rel(0.8)),
                  plot.margin=unit(c(10,5,5,5),"mm"),
                  strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
                  strip.text = element_text(face="bold")
          )
        
      }
      
      
      # plot    
      p <- ggplot(res, aes(x=variable, y=value, color = Density))
      p2 <- p +
        geom_jitter(shape=16, width = jitterwidth, height = 0,size= 4, alpha =1)+ 
        labs(x = x_label, y = y_label, color ="Density\n(a.u.)") +
        # labs(x = element_blank(), y = element_blank())+
        stat_summary(aes(group=1), fun=line_fun, geom="line", size=2, color= line_color)+ 
        stat_summary(aes(group=1), fun=line_fun, geom="point", size=6, color= line_color)+ 
        color_scale + 
        theme_Publication() +
        ylim(input$sidebar_yaxis_range_data[1],input$sidebar_yaxis_range_data[2])+
        ggtitle(title) 
      
      
      print(p2)  
    }
    
    # read file
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    heatscatter(read_csv(inFile$datapath), 
                line_fun = input$sumfunc_data,
                y_label = input$sidebar_yaxistitle_data,
                x_label = input$sidebarxaxistitle_data,
                title = input$plot_title_data,
                jitterwidth = input$jitterwidth_data)
    
  })
})