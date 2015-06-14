suppressMessages(library(dplyr))
library(magrittr)
library(dplyr)
library(shiny)
library(rmarkdown)
library(knitr)
library(DT)

## options for knitting/rendering rmarkdown chunks
knitr::opts_chunk$set(echo = FALSE, comment = NA, cache = FALSE,
                      message = FALSE, warning = FALSE)

student_info <- function(section, spath, img_type = ".jpg") {

  sinfo <- read.csv(paste0(spath, section, ".csv"), as.is=TRUE) %>%
    arrange(last_name, first_name)
    sinfo

  sinfo %<>% mutate(pref_name = ifelse(pref_name == "", first_name, pref_name))
  sinfo$id <- paste0(sinfo$first_name, ".", sinfo$last_name)
  sinfo$images <- paste0(spath, section, "/", sinfo$id, img_type)

  ## if an image is missing use a standard image
  sinfo$images[!file.exists(sinfo$images)] <- "student-info/zzz111.jpg"

  ## if images hosted on remove server
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
  rndmat <- matrix("", ncol = nr_col, nrow = ceiling(nr / nr_col)) %>%
    set_colnames(rep("", nr_col))
  rndmat[1:nr] <- ssample
  kable(rndmat, format = "markdown")
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
        actionButton("cold_call_button", "Cold call DT")
      ),
      fluidRow(
        htmlOutput("cold_call_table"),
        DT::dataTableOutput("cold_call_DT")
      )
    ),

    server = function(input, output, session) {
      output$cold_call_DT <- DT::renderDataTable({
        if(input$cold_call_button == 0) return()
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
    options = list(height = 80 + 100 * nr)
  )
}



