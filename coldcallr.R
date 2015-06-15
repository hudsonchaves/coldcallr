library(dplyr)
library(magrittr)
library(dplyr)
library(shiny)
library(rmarkdown)
library(knitr)
library(DT)

## options for knitting/rendering rmarkdown chunks
knitr::opts_chunk$set(echo = FALSE, comment = NA, cache = FALSE,
                      message = FALSE, warning = FALSE)

## if you are only using renderTable / xtable without col or row names
# options(xtable.include.rownames=F)
# options(xtable.include.colnames=F)

student_info <- function(section, spath, img_type = ".jpg") {

  sinfo <- read.csv(paste0(spath, "/", section, ".csv"), as.is = TRUE) %>%
    arrange(last_name, first_name)
    sinfo

  sinfo$group_name %<>% as.factor

  sinfo %<>% mutate(pref_name = ifelse(pref_name == "", first_name, pref_name))
  sinfo$id <- paste0(sinfo$first_name, ".", sinfo$last_name)
  sinfo$images <- paste0(spath, "/", section, "/", sinfo$id, img_type)

  ## if an image is missing use a standard image
  sinfo$images[!file.exists(sinfo$images)] <- "student-info/zzz111.jpg"

  ## if images are hosted on a remove server
  # site_path <- "http://your-remote-server-name/site_media/"
  # images <- paste0(site_path,images)

  sinfo$images <- with(sinfo, paste0("<img src='", images,"' title='", pref_name, " ", last_name,"' style='height:60px'>"))
  sinfo
}

section_email <- function(sinfo, email = "pref_email", sep = ";")
  paste0("<a href=\"mailto:", paste0(sinfo[[email]], collapse = sep), "\">Send section email: ", section, "</a>")

mem_names <- function(sinfo, nr_col = 8) {
  sinfo$images %<>% sub("height:[0-9]{2,3}px", "height:120px", .)
  nr <- nrow(sinfo)
  ssample <- sample(sinfo$images, nr)
  rndmat <- matrix(NA, ncol = nr_col, nrow = ceiling(nr / nr_col)) %>%
    set_colnames(rep("", nr_col))
  rndmat[1:nr] <- ssample
  rndmat[ ,apply(rndmat, 2, function(x) !any(is.na(x)))]
}

mem_table <- function(sinfo, btn, nr_col = 8) {
  renderTable({
    if(input[[btn]] == 0) return()
    mem_names(sinfo, nr_col)
  }, include.colnames = FALSE, include.rownames = FALSE,
     sanitize.text.function = identity)
}

cold_call <- function(sinfo, nr = 5) {
  sinfo$rnum <- runif(nrow(sinfo), min = 0, max = 1)
  sinfo %>%
    arrange(desc(rnum)) %>%
    # filter(group_name != "") %>%
    slice(1:nr) %>%
    select(rnum, pref_name, last_name, group_name, images) %>%
    mutate(rnum = round(rnum,3))
}

DT_simple <- function(sinfo, btn, nr = 4) {
  DT::renderDataTable({
    if(input[[btn]] == 0) return()
    cold_call(sinfo, nr = nr) %>%
      DT::datatable(rownames = FALSE, style = "bootstrap", escape = FALSE,
        options = list(
          paging = FALSE,
          searching = FALSE,
          searchable = FALSE,
          columnDefs = list(list(className = 'dt-center', targets = "_all")),
          autoWidth = TRUE,
          processing = FALSE
        )
      )
  })
}

DT_full <- function(sinfo) {
  DT::renderDataTable({
    DT::datatable(sinfo, filter = list(position = "top", clear = FALSE, plain = FALSE),
      rownames = FALSE, style = "bootstrap", escape = FALSE,
      options = list(
        search = list(regex = TRUE),
        columnDefs = list(list(className = 'dt-center', targets = "_all")),
        autoWidth = TRUE,
        processing = FALSE,
        pageLength = 10,
        lengthMenu = list(c(10, 25, 50, -1), c('10','25','50','All'))
      )
    )
  })
}

########################################
## function below not currently used
########################################
cold_call_shiny <- function(sinfo, nr = 5) {

  shinyApp(
    ui = fluidPage(
      tags$head(
        tags$style(HTML("
          .row {
            margin-right: auto;
            margin-left: auto;
          }"))
      ),
      fluidRow(
        actionButton("cold_call_button_shiny", "Cold call shiny")
      ),
      fluidRow(
        tableOutput("cold_call_table"),
        htmlOutput("cold_call_xtable"),
        DT::dataTableOutput("cold_call_DT")
      )
    ),

    server = function(input, output, session) {

      output$cold_call_table <- renderTable({
        if(input$cold_call_button_shiny == 0) return()
        cold_call(sinfo, nr = nr)
      }, sanitize.text.function = identity)

      output$cold_call_xtable <- renderText({
        if(input$cold_call_button_shiny == 0) return()
        cold_call(sinfo, nr = nr) %>%
        xtable::xtable(.) %>%
        print(type = "html",  print.results = FALSE, include.rownames = FALSE,
              sanitize.text.function=identity) %>%
        sub("<table border=*.1*.>","<table class='table table-condensed table-hover'>", .,
        perl = TRUE)
      })

      output$cold_call_DT <- DT::renderDataTable({
        if(input$cold_call_button_shiny == 0) return()
        cold_call(sinfo, nr = nr) %>%
          DT::datatable(rownames = FALSE, style = "bootstrap", escape = FALSE,
            options = list(
              paging = FALSE,
              searching = FALSE,
              searchable = FALSE,
              columnDefs = list(list(className = 'dt-center', targets = "_all")),
              autoWidth = TRUE,
              processing = FALSE
            )
          )
      })
    },
    options = list(width = "100%", height = 80 + 100 * nr)
  )
}



