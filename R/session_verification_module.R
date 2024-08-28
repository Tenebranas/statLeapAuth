library(shiny)
library(jsonlite)
library(httr)

loadConfig <- function() {
  cat("Starting loadConfig function...\n")
  library(jsonlite)
  config_path <- system.file("www/config.json", package = "statLeapAuth")
  cat("system.file returned path:", config_path, "\n")
  
  if (config_path == "") {
    stop("Config file not found.")
  }
  
  config <- fromJSON(config_path)
  cat("Config loaded successfully.\n")
  return(config)
}

sessionVerificationUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("verification_status")),
    uiOutput(ns("main_ui"))
  )
}

sessionVerificationServer <- function(id, main_ui_function) {
  moduleServer(id, function(input, output, session) {
    config <- loadConfig()
    server_url <- config$serverUrl
    
    verification_status <- reactiveVal("pending")
    
    observeEvent(input$session_id, {
      sessionId <- input$session_id
      userId <- input$user_id
      
      verification_result <- tryCatch({
        GET(
          url = paste0(server_url, "/verify-session"),
          add_headers(
            Authorization = paste("Bearer", sessionId),
            `x-user-id` = userId
          )
        )
      }, error = function(e) {
        NULL
      })
      
      if (!is.null(verification_result) && verification_result$status_code == 200) {
        verification_status("success")
      } else {
        verification_status("failed")
      }
    })
    
    output$verification_status <- renderUI({
      if (verification_status() == "pending") {
        tags$p("Verifying session, please wait...", style = "color: blue;")
      } else if (verification_status() == "failed") {
        tags$p("Session verification failed. The application will close.", style = "color: red;")
      }
    })
    
    output$main_ui <- renderUI({
      if (verification_status() == "success") {
        main_ui_function()
      } else if (verification_status() == "failed") {
        Sys.sleep(2)
        stopApp("Session verification failed.")
      }
    })
  })
}