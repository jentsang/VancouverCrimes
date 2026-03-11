library(shiny)
library(bslib)
library(readr)
library(leaflet)
library(dplyr)
library(sf) 

crime_df <- read_csv("data/crimedata_csv_AllNeighbourhoods_2025.csv")
crime_choices <- c(sort(unique(crime_df$TYPE)))

ui <- page_sidebar(
  title = "Vancouver Crimes",
  
  sidebar = sidebar(
    title = "Filters",
    selectInput(
      "crime_type",
      "Select Crime Type(s):",
      choices = crime_choices,
      selected = crime_choices[1],
      multiple = TRUE
    ),
    
    # select all and clear all button
    layout_column_wrap(
      width = 1/2,
      actionButton("select_all", "Select All", class = "btn-sm"),
      actionButton("clear_all", "Clear All", class = "btn-sm")
    )
  ),

  # OUTPUT 1& 2: max and min crimes + neighbourhoods
  layout_column_wrap(
    width = 1/2,
    fill = FALSE,
    value_box(
      title = "Highest Crime Neighbourhood",
      value = textOutput("max_crime_val"),
      theme = "danger",
      p(textOutput("max_crime_name"))
    ),
    value_box(
      title = "Lowest Crime Neighbourhood",
      value = textOutput("min_crime_val"),
      theme = "success",
      p(textOutput("min_crime_name"))
    )
  ),
    
  # OUTPUT 3: Map
  card(
    full_screen = TRUE,
    card_header("Crime Distribution Map"),
    leafletOutput("crime_map", height = "500px")
  )
)

server <- function(input, output, session) {
  
  # select all button
  observeEvent(input$select_all, {
    updateSelectInput(session, "crime_type", selected = crime_choices)
  })
  
  # clear all button
  observeEvent(input$clear_all, {
    updateSelectInput(session, "crime_type", selected = character(0))
  })
  
  filtered_stats <- reactive({
    req(input$crime_type)
    
    filtered_data <- crime_df |> 
      filter(TYPE %in% input$crime_type)
    
    filtered_data |> 
      filter(X != 0, Y != 0) |> 
      group_by(NEIGHBOURHOOD) |> 
      summarise(
        COUNT = n(),
        X = mean(X),
        Y = mean(Y)
      )
  })
  
  # max crime count
  output$max_crime_val <- renderText({
    stats <- filtered_stats()
    paste(max(stats$COUNT), "Incidents")
  })
  
  # max crime neighbourhood
  output$max_crime_name <- renderText({
    stats <- filtered_stats()
    stats$NEIGHBOURHOOD[which.max(stats$COUNT)]
  })
  
  # min crime count
  output$min_crime_val <- renderText({
    stats <- filtered_stats()
    paste(min(stats$COUNT), "Incidents")
  })
  
  # min crime neighbourhood
  output$min_crime_name <- renderText({
    stats <- filtered_stats()
    stats$NEIGHBOURHOOD[which.min(stats$COUNT)]
  })
  
  # map 
  output$crime_map <- renderLeaflet({
    stats <- filtered_stats()
    req(nrow(stats) > 0)
    
    # convert UTM to GPS 
    map_data <- stats |> 
      st_as_sf(coords = c("X", "Y"), crs = 32610) |> 
      st_transform(crs = 4326)
    
    # extract coordinates for mapping
    coords <- st_coordinates(map_data)
    map_data$LON <- coords[,1]
    map_data$LAT <- coords[,2]
    
    # define current max and min 
    current_max <- max(map_data$COUNT)
    current_min <- min(map_data$COUNT)
    
    map_data <- map_data |> 
      mutate(
        marker_color = case_when(
          COUNT == current_max ~ "#dc3545", 
          COUNT == current_min ~ "#198754",
          TRUE ~ "steelblue" 
        ),
        marker_opacity = 0.5
      )
    
    # 4. Render Map
    leaflet(map_data) |> 
      addTiles() |> 
      setView(lng = -123.11, lat = 49.25, zoom = 11) |> 
      addCircleMarkers(
        lng = ~LON, lat = ~LAT,
        radius = ~ (5 + sqrt(COUNT / current_max) * 40),
        color = ~marker_color,
        fillColor = ~marker_color,
        fillOpacity = ~marker_opacity,
        stroke = TRUE,
        weight = 2,
        popup = ~paste0("<b>", NEIGHBOURHOOD, "</b><br>Count: ", COUNT)
      )
  })
}

shinyApp(ui = ui, server = server)