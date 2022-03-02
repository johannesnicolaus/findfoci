library(shiny)



# fileinput
file_input <- fileInput("file1", "Choose csv File",
                        accept = c(
                          "text/csv",
                          "text/comma-separated-values,text/plain",
                          ".csv")
)

# summary function

sumfunc <- radioButtons("sumfunc_data", h4("Summarization method"), 
            choices = list("median" = "median", "mean" = "mean"), selected = "median")

# logfunc
logfunc <- radioButtons("logfunc_data", h4("Data transformation method"), 
                        choices = list("log2(n+1)" = "log2_1", "ln(n+1)" = "loge_1",
                                       "log10(n+1)" = "log10_1"), selected = "log2_1")


# jitter width

jitterwidth <- sliderInput("jitterwidth_data", "Jitter width",
                           min = 0, max = 1, value = c(0.1))

# color palette

# colpalette <- radioButtons("colpalette_data", h4("Select which color palette to use"), 
#                         choices = list("viridis" = "scale_color_viridis()", "blue_black" = "scale_color_continuous()"), selected = 1)


# x axis
sidebar_xaxistitle <- textInput("sidebarxaxistitle_data", h4("X axis title"), 
          value = "Time (min)")  

# sidebar_xaxis_range <- sliderInput("sidebar_xaxis_range_data", "X axis range",
#                                    min = 0, max = 100, value = c(25, 75))

# y axis
sidebar_yaxistitle <- textInput("sidebar_yaxistitle_data", h4("Y axis title"), 
                           value = "log2(Foci number + 1)")  

sidebar_yaxis_range <- sliderInput("sidebar_yaxis_range_data", "Y axis range",
                                   min = 0, max = 20, value = c(0, 6), step = 0.5)

# plot title 
plot_title <- textInput("plot_title_data", h4("Plot title"), 
                        value = "Enter text...")  

# Define UI 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Heatscatter plot of foci"),
  
  sidebarPanel(
    file_input,
    sumfunc,
    jitterwidth,
    logfunc,
    # colpalette,
    plot_title,
    sidebar_xaxistitle,
#    sidebar_xaxis_range,
    sidebar_yaxistitle,
    sidebar_yaxis_range
  ),
  
  mainPanel(plotOutput("heatscatterplot", height = "600px"),
            textOutput("tbl_dims"),
            div(style="height:600px; overflow:scroll; align:text-center",
                tableOutput("contents")
                )
            )
))