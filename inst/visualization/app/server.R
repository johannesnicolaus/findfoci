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

    read.csv(inFile$datapath, stringsAsFactors = F)
  }, align = "c", width = "100%")

  # print table dimensions
  output$tbl_dims <- renderText({
    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)

    csvfile <- read.csv(inFile$datapath)

    paste("Number of samples:" , dim(csvfile)[1])
  })


# renderplot --------------------------------------------------------------

  output$heatscatterplot <- renderPlot({

    heatscatter <- function(data, color_scale = ggplot2::scale_color_viridis_c(),
                            line_color = "#ef3b2c",
                            line_fun = "median",
                            jitterwidth = 0.1,
                            x_label = "Time (min)",
                            y_label = "log2(Foci number + 1)",
                            title = ggplot2::element_blank()){

      data1 <- data

      factor_time <- data1$time

      # transformed data
      if (input$logfunc_data == "log2_1") {
        log_transformed <- dplyr::mutate(data1, foci_count = log2(foci_count +1))
      } else if (input$logfunc_data == "loge_1") {
        log_transformed <- dplyr::mutate(data1, foci_count = log(foci_count +1))
      } else if (input$logfunc_data == "log10_1") {
        log_transformed <- dplyr::mutate(data1, foci_count = log10(foci_count +1))
      } else {log_transformed <- dplyr::mutate(data1, foci_count = log2(foci_count +1))}


      res <- c()

      # calculate density at each time point
      for(i in unique(factor_time)){
        variable_filter <- dplyr::filter(log_transformed, time == i)
        variable_filter <- dplyr::arrange(variable_filter, foci_count)
        variable_filter$Density<- stats::density(variable_filter$foci_count, n=length(variable_filter$foci_count))$y
        res <- rbind(res, variable_filter)
      }


      # theme
      theme_Publication <- function(base_size=40) {
        ggplot2::theme_bw(base_size=base_size)+
          ggplot2::theme(plot.title = ggplot2::element_text(size = ggplot2::rel(1.2), hjust = 0.5),
                  text = ggplot2::element_text(),
                  panel.background = ggplot2::element_rect(colour = NA),
                  plot.background = ggplot2::element_rect(colour = NA),
                  panel.border = ggplot2::element_rect(colour = "black"),
                  axis.title = ggplot2::element_text(size = ggplot2::rel(0.8)),
                  #            axis.title.y = element_text(angle=90,vjust =2),
                  #            axis.title.x = element_text(vjust = -0.2),
                  axis.text = ggplot2::element_text(),
                  #            axis.line = element_line(colour="black"),
                  axis.ticks = ggplot2::element_line(),
                  panel.grid.major = ggplot2::element_blank(),
                  panel.grid.minor = ggplot2::element_blank(),
                  legend.key = ggplot2::element_rect(colour = NA),
                  legend.position = "right",
                  legend.direction = "vertical",
                  legend.key.size= ggplot2::unit(1, "cm"),
                  legend.title = ggplot2::element_text(size = ggplot2::rel(0.8)),
                  plot.margin=ggplot2::unit(c(10,5,5,5),"mm"),
                  strip.background=ggplot2::element_rect(colour="#f0f0f0",fill="#f0f0f0"),
                  strip.text = ggplot2::element_text(face="bold")
          )

      }


      # plot
      p <- ggplot2::ggplot(res, ggplot2::aes(x=as.factor(time), y=foci_count, color = Density))
      p2 <- p +
        ggplot2::geom_jitter(shape=16, width = jitterwidth, height = 0,size= 4, alpha =1)+
        ggplot2::labs(x = x_label, y = y_label, color ="Density\n(a.u.)") +
        # labs(x = element_blank(), y = element_blank())+
        ggplot2::stat_summary(ggplot2::aes(group=1), fun=line_fun, geom="line", size=2, color= line_color)+
        ggplot2::stat_summary(ggplot2::aes(group=1), fun=line_fun, geom="point", size=6, color= line_color)+
        color_scale +
        theme_Publication() +
        ggplot2::ylim(input$sidebar_yaxis_range_data[1],input$sidebar_yaxis_range_data[2])+
        ggplot2::ggtitle(title)


      print(p2)
    }

    # read file
    inFile <- input$file1

    if (is.null(inFile))
      return(NULL)

    set.seed(1)
    heatscatter(read.csv(inFile$datapath),
                line_fun = input$sumfunc_data,
                y_label = input$sidebar_yaxistitle_data,
                x_label = input$sidebarxaxistitle_data,
                title = input$plot_title_data,
                jitterwidth = input$jitterwidth_data)

  })
})
