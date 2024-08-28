sessionVerificationUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("verification_status")),
    uiOutput(ns("main_ui"))
  )
}

sessionVerificationServer <- function(id, main_ui_function) {
  moduleServer(id, function(input, output, session) {
    
    # Load the configuration (assuming loadConfig is already defined)
    config <- loadConfig()
    server_url <- config$serverUrl  # Get the server URL from the config
    
    # Reactive value to track verification status
    verification_status <- reactiveVal("pending") # pending, success, or failed
    
    observeEvent(input$session_id, {
      sessionId <- input$session_id
      userId <- input$user_id  # Assume you get the userId from the postMessage event
      
      # Make a request to verify the session
      verification_result <- tryCatch({
        httr::GET(
          url = paste0(server_url, "/verify-session"),
          httr::add_headers(
            Authorization = paste("Bearer", sessionId),
            `x-user-id` = userId  # Send the userId in the headers or body
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
    
    # UI for verification status
    output$verification_status <- renderUI({
      if (verification_status() == "pending") {
        tags$p("Verifying session, please wait...", style = "color: blue;")
      } else if (verification_status() == "failed") {
        tags$p("Session verification failed. The application will close.", style = "color: red;")
      }
    })
    
    # Conditional main UI based on verification status
    output$main_ui <- renderUI({
      if (verification_status() == "success") {
        # Call the provided main UI function
        main_ui_function()
      } else if (verification_status() == "failed") {
        Sys.sleep(2)  # Optional: Delay to allow the user to see the failure message
        stopApp("Session verification failed.")
      }
    })
  })
}