library(shiny)
library(shinyWidgets)
library(datamods)

# Austrian first names from 1984-2020 
# thanks Vienna https://www.statistik.at/web_de/statistiken/menschen_und_gesellschaft/bevoelkerung/geborene/vornamen/index.html
# thanks dreamRs https://dreamrs.github.io/datamods/reference/filter-data.html


# df <- read.csv2("names austria all v1.csv", header = TRUE, sep = ";", skip = 0, fileEncoding="UTF-8") 
df <- read.csv2("names austria all v1.csv", header = TRUE, sep = ";", skip = 0, fileEncoding="latin1") 

# df <- readRDS("../data/df.rds")
# dataset <- readRDS("../data/df.rds")

ui <- fluidPage(
  tags$h2("Filter data.frame"),

  radioButtons(
    inputId = "dataset",
    label = "Data:",
    choices = c(

      "df"
    ),
    inline = TRUE
  ),

  fluidRow(
    column(
      width = 3,
      filter_data_ui("filtering", max_height = "500px")
    ),
    column(
      width = 9,
      progressBar(
        id = "pbar", value = 100,
        total = 100, display_pct = TRUE
      ),
      DT::dataTableOutput(outputId = "table"),
      tags$b("Code dplyr:"),
      verbatimTextOutput(outputId = "code_dplyr"),
      tags$b("Expression:"),
      verbatimTextOutput(outputId = "code"),
      tags$b("Filtered data:"),
      verbatimTextOutput(outputId = "res_str")
    )
  )
)

server <- function(input, output, session) {

  data <- reactive({
    get(input$dataset)
  })

  vars <- reactive({

  })

  res_filter <- filter_data_server(
    id = "filtering",
    data = data,
    name = reactive(input$dataset),
    vars = vars,
    widget_num = "slider",
    widget_date = "slider",
    label_na = "Missing"
  )

  observeEvent(res_filter$filtered(), {
    updateProgressBar(
      session = session, id = "pbar",
      value = nrow(res_filter$filtered()), total = nrow(data())
    )
  })

  output$table <- DT::renderDT({
    res_filter$filtered()
  }, options = list(pageLength = 20))


  output$code_dplyr <- renderPrint({
    res_filter$code()
  })
  output$code <- renderPrint({
    res_filter$expr()
  })

  output$res_str <- renderPrint({
    str(res_filter$filtered())
  })

}

shinyApp(ui = ui, server = server)

# if (interactive())
  # shinyApp(ui, server)