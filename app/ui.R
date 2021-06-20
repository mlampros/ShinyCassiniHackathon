

shinydashboard::dashboardPage(skin = "purple",

                              shinydashboard::dashboardHeader(
                                title = "Team: Gen XYZ, Project: Go Green!",
                                titleWidth = 500
                              ),                                                                            # SEE: https://rstudio.github.io/shinydashboard/appearance.html#long-titles

                              shinydashboard::dashboardSidebar(

                                width = 215,

                                shinydashboard::sidebarMenu(id = 'my_sidebar',

                                                            shiny::hr(),

                                                            shinydashboard::menuItem(text = "Administrative Level",
                                                                                     tabName = "dashboard",
                                                                                     icon = shiny::icon("tablet-alt")),
                                                            shiny::hr(),
                                                            
                                                            shiny::uiOutput(outputId = "select_city"),

                                                            shiny::selectInput(inputId = 'leaf_providers',
                                                                               label ='Leaflet providers:',
                                                                               choices = leaflet::providers,
                                                                               selected = leaflet::providers$CartoDB.Positron,
                                                                               multiple = FALSE,
                                                                               width="250px"),
                                                            
                                                            shiny::hr(),
                                                            
                                                            shinydashboard::menuItem(text = "Selected Green Space",
                                                                                     tabName = "green_space_mitem",
                                                                                     icon = shiny::icon("images")),

                                                            shiny::hr(),
                                                            
                                                            shinydashboard::menuItem(text = "3D Administrative Boundaries",
                                                                                     tabName = "3d_admin",
                                                                                     icon = shiny::icon("unity")),
                                                            
                                                            shiny::hr(),
                                                            
                                                            shinydashboard::menuItem(text = "Open Street Map Routing",
                                                                                     tabName = "osm_route",
                                                                                     icon = shiny::icon("route")),
                                                            
                                                            shiny::hr(),

                                                            shinydashboard::menuItem(text = "ABOUT",
                                                                                     tabName = "widgets",
                                                                                     icon = shiny::icon("info-circle"),
                                                                                     selected = TRUE),                                                  # use 'selected = TRUE' in the 'ABOUT' sidebar to avoid opening the popup-window when I start the shiny application
                                                            shiny::hr(),

                                                            shinyjs::useShinyjs(),                                                                      # Include shinyjs in the UI
                                                            shinyjs::extendShinyjs(text = "shinyjs.reset = function() {history.go(0)}", functions = c("reset")),                                              # Add the js code to the page
                                                            shiny::actionButton(inputId =  "reset_button", label = "Restart shiny", icon = shiny::icon("fas fa-sync-alt"), style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
                                )
                              ),

                              shinydashboard::dashboardBody(

                                # 1st. add some custom CSS to make the title background area the same color as the rest of the header  [ see: https://rstudio.github.io/shinydashboard/appearance.html#css ]
                                # 2nd. change the letters to bold and the font size  [ see:  https://stackoverflow.com/a/53562689/8302386 ]

                                htmltools::tags$head(htmltools::tags$style(htmltools::HTML('.skin-blue .main-header .logo {
                                                                  background-color: #3c8dbc;
                                                                  font-family: "Georgia", Times, "Times New Roman", serif;
                                                                  font-weight: bold;
                                                                  font-size: 24px;
                                                                  }
                                                                  .skin-blue .main-header .logo:hover {
                                                                  background-color: #3c8dbc;
                                                                  }
                                                                  .main-sidebar {
                                                                  font-weight: bold;
                                                                  font-size: 13px;
                                                                  }"'))),


                                shinydashboard::tabItems(
                                  shinydashboard::tabItem(tabName = "dashboard",
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 6, status = "info", solidHeader = TRUE,
                                                              title = "Map in 'Municipality' level",
                                                              mapview::mapviewOutput(outputId = "leaf_map", width = "100%", height = 750)
                                                            ),
                                                            shinydashboard::box(
                                                              width = 6, status = "info", solidHeader = TRUE,
                                                              title = "Particle values in 'Spatial Pixel' level",
                                                              mapview::mapviewOutput(outputId = "leaf_map_pixel", width = "100%", height = 750)
                                                            )
                                                          ),
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 12, status = "info", solidHeader = TRUE,
                                                              title = "Green Spaces of selected Municipality",
                                                              DT::dataTableOutput(outputId = "global_dtable", width = "100%", height = 200)
                                                            )
                                                          )
                                  ),
                                  
                                  shinydashboard::tabItem(tabName = "green_space_mitem",
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 6, status = "info", solidHeader = TRUE,
                                                              title = "Time Series Line Plot",
                                                              plotly::plotlyOutput(outputId = "plt_lines", width = "100%", height = "375px")
                                                            ),
                                                            shinydashboard::box(
                                                              width = 6, status = "info", solidHeader = TRUE,
                                                              title = "Year Month Bar Plot",
                                                              plotly::plotlyOutput(outputId = "plt_barplot", width = "100%", height = "375px")
                                                            )
                                                          ),
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 6, status = "info", solidHeader = TRUE,
                                                              title = "Sentinel-2 Analysis Ready Image of the Selected Green Space",
                                                              shiny::imageOutput(outputId = "s2_img", width = "100%", height = "450px")
                                                            ),
                                                            shinydashboard::box(
                                                              width = 6, status = "info", solidHeader = TRUE,
                                                              title = "High resolution Image of the Selected Green Space",
                                                              shiny::imageOutput(outputId = "leafl_img", width = "100%", height = "450px")
                                                            )
                                                          )
                                  ),
                                  
                                  shinydashboard::tabItem(tabName = "3d_admin",
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 12, status = "info", solidHeader = TRUE,
                                                              title = "3-Dimensional Elevation Model of the Administrative Boundary",
                                                              rgl::rglwidgetOutput(outputId = "raysh_3d_out", width = "100%", height = "850px")
                                                            )
                                                          )
                                  ),
                                  
                                  shinydashboard::tabItem(tabName = "osm_route",
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 12, status = "info", solidHeader = TRUE,
                                                              title = "Give the Input Well Known Text (WKT) in form of a POINT for your location (Use CRS 4326):",
                                                              shiny::textInput(inputId = "WKT", label = "", value = "POINT (23.73643398284912 37.97556369908082)", width = '100%')
                                                            )
                                                          ),
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 3, status = "info", solidHeader = TRUE,
                                                              title = "Time to Destination (in minutes):",
                                                              shiny::column(3, shiny::uiOutput(outputId = "osm_time", label = "Time to the Green Space (in minutes):"))
                                                            ),
                                                            shinydashboard::box(
                                                              width = 4, status = "info", solidHeader = TRUE,
                                                              title = "Distance to Destination (in kilometers)",
                                                              shiny::column(2, shiny::uiOutput(outputId = "osm_distance", label = "Distance to the Green Space (in kilometers):"))
                                                            )
                                                          ),
                                                          shiny::fluidRow(
                                                            shinydashboard::box(
                                                              width = 12, status = "info", solidHeader = TRUE,
                                                              title = "Open Street Map Routing to the Green Space",
                                                              mapview::mapviewOutput(outputId = "route_map", width = "100%", height = 560)
                                                            )
                                                          )
                                  ),
                                  
                                  shinydashboard::tabItem(tabName = "widgets",
                                                          shinydashboardPlus::userBox(
                                                            title = shinydashboardPlus::userDescription(title = "Team: Gen XYZ, Project: Go Green!",
                                                                                                        subtitle = "Cassini Hackathon Greece, June 2021",
                                                                                                        type = NULL,
                                                                                                        image = 'https://www.corallia.org/images/CASSINI.jpg',
                                                                                                        backgroundImage = "https://images.pexels.com/photos/531880/pexels-photo-531880.jpeg?auto=compress&cs=tinysrgb&h=350"
                                                            ),
                                                            closable = FALSE,
                                                            maximizable = TRUE,
                                                            "",                                         # let this empty otherwise it is overshadowed by my photo
                                                            footer = htmltools::HTML('<p style="font-family: times; font-size:13pt; font-style:normal; color: purple">This interactive shiny application allows the user to pick a city around the world. The city boundaries are split based on a pre-specified admin-level
                                that captures the natural boundaries of the municipalities. The user can interactively choose one of the municipalities to explore / visualize the available green spaces). More details are included in the <b>popup</b> windows once clicked to the Menu Items on the left side.</p>')                                                          )
                                  )
                                ),

                                shinybusy::add_busy_spinner(spin = "atom",
                                                            position = "top-left",
                                                            margins = c(0, 10),
                                                            height = "50px",
                                                            width = "50px",
                                                            color = "#FFF")            # spinner for shinydashboard, SEE:  https://github.com/dreamRs/shinybusy/issues/5#issuecomment-587868208  [ for the spinner-options SEE: https://cran.r-project.org/web/packages/shinybusy/vignettes/spinners.html ]
                              )
)
