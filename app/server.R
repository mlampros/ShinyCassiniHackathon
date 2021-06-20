
#.....................................................................
# NOTES:
#
#  I have the option to switch to AOD 055 µm (I currently use AOD_047)
#.....................................................................


shiny::shinyServer(function(input, output, session) {
  
  REACTIV <- shiny::reactiveValues()
  REACTIV$CITY <- NULL
  REACTIV$ADMIN <- NULL
  REACTIV$GREEN_SPACES <- NULL
  REACTIV$leaf_MAP <- NULL
  REACTIV$leaf_MAP_PIXEL <- NULL
  REACTIV$VIZ_SUBS <- NULL
  REACTIV$AOD_047 <- NULL
  REACTIV$three_D_VIZ <- NULL

  
  shiny::observeEvent(input$reset_button, {                                     # Call the method from somewhere within the server to restart the shiny application
    shinyjs::js$reset()
  })
  
  
  DTproxy <- DT::dataTableProxy("global_dtable", session = session)

  shiny::observeEvent(input$my_sidebar, {

    if (shiny::isTruthy(input$my_sidebar)) {
      if (input$my_sidebar == "dashboard") {

        TITLE = "Information about the <b>Administrative Level</b> (Sidebar Menu Item)"
        MESSAGE = "The user is first asked to choose a <b>City</b> from the drop-down menu for which the Municipalities will appear. Then once clicked on one of the Municipalities <b>1st.</b> a second leaflet map will show on the right with all Green Spaces of the selected Municipality and <b>2nd.</b> Tabular data (below the Maps) will show all named OpenStreetMap Green Spaces in the Municipality with additional information that allows the user to restrict the search to a specific Area of Interest."
        popup_window_message(title = TITLE,
                             message = MESSAGE,
                             size = 'm',
                             title_attributes = list(font_family = 'times', font_size = 15, font_style = 'italic', color = 'blue', text_align = 'center'),
                             message_attributes = list(font_family = 'times', font_size = 13, font_style = 'normal', color = 'black', text_align = 'left'),
                             easyClose = TRUE)
      }
      
      if (input$my_sidebar == "green_space_mitem") {
        
        TITLE = "Information about the <b>Selected Green Space</b> (Sidebar Menu Item)"
        MESSAGE = "This Menu item shows in the <b>first row 2 Plotly</b> Visualizations: <b>1st.</b> a Time Series Line Plot of the last 60 days and <b>2nd</b>. a bar plot of aggregated Aerosol Optical Depth (AOD) values on a monthly basis in which we compare the AOD between the <b>selected Administrative Level</b> and the <b>selected Green Space</b>. In the <b>second row</b> we show the area of the Green space utilizing a <b>Sentinel-2</b> and a <b>High Resolution</b> imagery"
        popup_window_message(title = TITLE,
                             message = MESSAGE,
                             size = 'm',
                             title_attributes = list(font_family = 'times', font_size = 15, font_style = 'italic', color = 'blue', text_align = 'center'),
                             message_attributes = list(font_family = 'times', font_size = 13, font_style = 'normal', color = 'black', text_align = 'left'),
                             easyClose = TRUE)
      }
      
      if (input$my_sidebar == "3d_admin") {
        
        TITLE = "Information about the <b>3-Dimensional Elevation Model</b> (Sidebar Menu Item)"
        MESSAGE = "This Menu item shows the 3-Dimensional Elevation Model of the selected <b>Administrative Level Area</b>"
        popup_window_message(title = TITLE,
                             message = MESSAGE,
                             size = 'm',
                             title_attributes = list(font_family = 'times', font_size = 15, font_style = 'italic', color = 'blue', text_align = 'center'),
                             message_attributes = list(font_family = 'times', font_size = 13, font_style = 'normal', color = 'black', text_align = 'left'),
                             easyClose = TRUE)
      }
      
      
      if (input$my_sidebar == "osm_route") {
        
        TITLE = "Information about the <b>Open Street Map Routing</b> (Sidebar Menu Item)"
        MESSAGE = "This Menu item allows the user to give as input a <b>Well Known Text (WKT)</b> and it returns the <b>Open Street Map route</b> to the selected <b>Green Space</b> in <b>red</b> color. Moreover, it shows the <b>time</b> and <b>distance</b> to the destination</b>"
        popup_window_message(title = TITLE,
                             message = MESSAGE,
                             size = 'm',
                             title_attributes = list(font_family = 'times', font_size = 15, font_style = 'italic', color = 'blue', text_align = 'center'),
                             message_attributes = list(font_family = 'times', font_size = 13, font_style = 'normal', color = 'black', text_align = 'left'),
                             easyClose = TRUE)
      }
      
      # print("#.......................#")
      # print(input$my_sidebar)
    }
  })

  
  shiny::observeEvent(input$select_city, {
    REACTIV$CITY <- input$select_city
  })
  
  
  shiny::observeEvent(REACTIV$CITY, {                                                                                     # resetting of the variables is done when I switch from one city to another
    
    clear_leaflet_console(mapID = 'leaf_map', Session = session, leaflet_provider = input$leaf_providers)
    clear_leaflet_console(mapID = 'leaf_map_pixel', Session = session, leaflet_provider = input$leaf_providers)
    
    REACTIV$leaf_MAP <- NULL
    REACTIV$leaf_MAP_PIXEL <- NULL
    REACTIV$VIZ_SUBS <- NULL
  })
  
  
  output$select_city = shiny::renderUI({
    
    shiny::selectInput(inputId = "select_city",
                       label = "Limit of City Population",
                       choices = c('Athens', 'Rome', 'Paris', 'Madrid', 'Berlin', 'London'),         # just a sample of european cities for illustration
                       selected = 'Athens')
  })
  
  
  shiny::observeEvent(REACTIV$CITY, {
    
    if (shiny::isTruthy(REACTIV$CITY)) {
      
      if (REACTIV$CITY == 'Athens') {
        
        load_admin_bounds = readRDS('data/adm_ar.RDS')
        REACTIV$ADMIN = load_admin_bounds
        # print(str(load_admin_bounds))

        load_green_spaces = readRDS('data/municipality_contains_green_spaces.RDS')
        
        if (remove_no_name_geoms) {                                                    # remove those green spaces observations that do not have a name
          idx = which(load_green_spaces$name == "")
          load_green_spaces = load_green_spaces[-idx, ]
        }
        
        REACTIV$GREEN_SPACES = load_green_spaces
        # print(load_green_spaces)
        
        load_aod_047 = data.table::fread('data/AOD_47_buffer_1km.csv', stringsAsFactors = F, header = T, nThread = parallel::detectCores())
        REACTIV$AOD_047 = load_aod_047
        # print(load_aod_047)
      }
    }
  })
  
  
  shiny::observeEvent(c(REACTIV$ADMIN,
                        input$leaf_providers), {  
                          
                          if (shiny::isTruthy(REACTIV$ADMIN)) {
                            if (shiny::isTruthy(input$leaf_providers)) {
                              
                              unq_colors_municipalities = unique(as.vector(na.omit(REACTIV$ADMIN$percentage_green)))
                              
                              lft_municip_green_sp = mapview::mapview(x = REACTIV$ADMIN,
                                                                      layerId = REACTIV$ADMIN$osm_id,
                                                                      map.types = c(input$leaf_providers, 'Esri.WorldImagery', 'OpenStreetMap.Mapnik'),
                                                                      zcol = "percentage_green",
                                                                      col.regions = RColorBrewer::brewer.pal(n = length(unq_colors_municipalities), name = "YlGn"),
                                                                      legend = TRUE,
                                                                      layer.name = 'percentage_green',
                                                                      popup = leafpop::popupTable(x = REACTIV$ADMIN,
                                                                                                  feature.id = TRUE,               # adds the 'osm_id' as feature-id to the data
                                                                                                  zcol =  c('name.en',
                                                                                                            'population',
                                                                                                            'rank_population',
                                                                                                            'area_municipality',
                                                                                                            'num_green_spaces',
                                                                                                            'percentage_green')))
                              output$leaf_map <- mapview::renderMapview({
                                lft_municip_green_sp
                              })
                            }
                          }
                        })
  
  
  shiny::observeEvent(input$leaf_map_shape_click, {
    REACTIV$leaf_MAP = input$leaf_map_shape_click
  })
  
  
  shiny::observeEvent(c(REACTIV$leaf_MAP,
                        REACTIV$GREEN_SPACES,
                        input$leaf_providers), {
                          
                          if (shiny::isTruthy(REACTIV$leaf_MAP)) {
                            if (shiny::isTruthy(REACTIV$GREEN_SPACES)) {
                              if (shiny::isTruthy(input$leaf_providers)) {
                                
                                on_click_data <- REACTIV$leaf_MAP                                      # see  https://rstudio.github.io/leaflet/shiny.html
                                osm_id = on_click_data$id
                                
                                idx_subs = which(REACTIV$GREEN_SPACES$osm_id == osm_id)
                                
                                viz_subs = REACTIV$GREEN_SPACES[idx_subs, ]
                                
                                REACTIV$VIZ_SUBS = viz_subs
                                
                                if (nrow(viz_subs) > 0) {
                                  
                                  pal_blue = grDevices::colorRampPalette(colors = c('gray', 'blue'))                                                     # see: https://github.com/r-spatial/mapview/issues/219#issuecomment-497046403
                                  SEQ_COLOR = seq(from = 0, to = ceiling(max(viz_subs$log_green_area)) + 0.5, by = 2.5)        # !!! Make sure that this sequence includes all values (take into consideration the 'by' step of 2.5)
                                  
                                  viz_mpv = mapview::mapview(x = viz_subs,
                                                             layerId = viz_subs$cluster,
                                                             map.types = c(input$leaf_providers, 'Esri.WorldImagery', 'OpenStreetMap.Mapnik'),
                                                             zcol = "log_green_area",
                                                             legend = TRUE,
                                                             col.regions = pal_blue,
                                                             at = rev(SEQ_COLOR),
                                                             layer.name = 'log_green_area',
                                                             popup = leafpop::popupTable(x = viz_subs,
                                                                                         feature.id = FALSE,                            # adds the 'osm_id' as feature-id to the data
                                                                                         zcol =  c('osm_id',
                                                                                                   'name',
                                                                                                   'area_green_spaces')))
                                  output$leaf_map_pixel <- mapview::renderMapview({
                                    viz_mpv
                                  })
                                  
                                  if (is.null(REACTIV$three_D_VIZ)) {            # create the rayshader 3D only if it not already exists
                                    
                                    raysh_pth = glue::glue('data/Elevation_admin_level/CopernicusDEM_osm_id_{osm_id}.tif')
                                    raysh_rst = raster::raster(raysh_pth)
                                    
                                    output$raysh_3d_out <- rgl::renderRglwidget({
                                      
                                      snapshot_rayshader_path = tempfile(fileext = '.png')
                                      
                                      rgl::open3d(useNULL = TRUE)                       # this removes the second rgl-popup-window
                                      
                                      rayshader_3d_DEM(rst_buf = raysh_rst,
                                                       zoom = 0.5,
                                                       windowsize = c(1600, 1000),
                                                       verbose = FALSE)
                                      
                                      rgl::rgl.snapshot(snapshot_rayshader_path)
                                      rgl::par3d(mouseMode = "trackball")   # options: c("trackball", "polar", "zoom", "selecting")
                                      rgl::rglwidget()

                                    })
                                  }
                                  
                                  # show specific columns in the data.table
                                  # consider adding also: 'min_AOD_55_1km', 'mean_AOD_55_1km', 'max_AOD_55_1km'
                                  
                                  viz_subs = data.table::data.table(viz_subs)
                                  
                                  keep_cols = c('name', 'area_green_spaces', 'min_elevation', 'mean_elevation', 'max_elevation',
                                                'min_tree_coverage', 'mean_tree_coverage', 'max_tree_coverage', 'min_AOD_47_1km', 
                                                'mean_AOD_47_1km', 'max_AOD_47_1km')
                                  
                                  viz_subs = viz_subs[, ..keep_cols]
                                  
                                  keep_digits = 4
                                  viz_subs[,(keep_cols[-1]) := round(.SD, digits = keep_digits), .SDcols = keep_cols[-1]]         # round to 'digits' and exclude the 1st. column from rounding
                                  
                                  colnames(viz_subs)[2] = 'area_green'
                                  
                                  output$global_dtable <- DT::renderDataTable(
                                    viz_subs,
                                    server = TRUE,
                                    rownames = FALSE,
                                    extensions = 'Buttons',
                                    selection = list(mode = 'single', target = 'row'),                     # 'renderDataTable()' will display the output  [ for 'single' row selection see : https://github.com/rstudio/DT/issues/324 ]
                                    options = list(pageLength = 10,
                                                   dom = 'Bfrtip',
                                                   buttons = list(list(extend = 'csv',
                                                                       filename = glue::glue('green_space_OpenStreetMap_ID_{osm_id}'))))                                       # DT regarding options see : https://rstudio.github.io/DT/options.html
                                  )
                                }
                                else {
                                  
                                  this_msg = "There are NO green spaces for this municipality!"
                                  message(this_msg)
                                  shiny::showNotification(this_msg, type = "error")
                                  
                                  REACTIV$VIZ_SUBS <- NULL
                                  output$leaf_map_pixel <- NULL
                                }
                              }
                            }
                          }
                        })
  
  
  shiny::observeEvent(REACTIV$leaf_MAP, {
    REACTIV$leaf_MAP_PIXEL <- NULL                # I have to set the ID of the green space to NULL whenever I switch to another municipality
    REACTIV$three_D_VIZ <- NULL
  })


  shiny::observeEvent(input$leaf_map_pixel_shape_click, {
    REACTIV$leaf_MAP_PIXEL = input$leaf_map_pixel_shape_click
  })


  shiny::observeEvent(input$global_dtable_rows_selected, {                                    # this is needed otherwise resetting of the rows does not work!

    clear_leaflet_console(mapID = 'local_map', Session = session, leaflet_provider = input$leaf_providers)         # reset the leaflet map

    if (length(input$global_dtable_rows_selected) != 0) {                  # this is needed otherwise resetting of the rows does not work!
      REACTIV$choosen_ROW <- input$global_dtable_rows_selected
    }
  })
  
  
  shiny::observeEvent(DTproxy, {                                           # to reset the selected row of the 'DT' I have to set the proxy equal to an empty list ( NULL does not work )

    REACTIV$choosen_ROW <- NULL
    DT::selectRows(DTproxy, list())
  })


  shiny::observeEvent(c(REACTIV$choosen_ROW,
                        REACTIV$VIZ_SUBS,
                        REACTIV$AOD_047), {

                          if (shiny::isTruthy(REACTIV$choosen_ROW)) {
                            if (shiny::isTruthy(REACTIV$VIZ_SUBS)) {
                              if (shiny::isTruthy(REACTIV$AOD_047)) {

                                select_row_dat = REACTIV$VIZ_SUBS[REACTIV$choosen_ROW, ]
                                # print(select_row_dat)
                                # print(as.character(select_row_dat$osm_id))
                                
                                plt_res = plotly_admin_level_green_space(AOD_data = REACTIV$AOD_047, 
                                                                         admin_level_id = as.character(select_row_dat$osm_id),
                                                                         green_space_id = as.integer(REACTIV$choosen_ROW),
                                                                         last_n_days = 60)                                           # by default use 60 days for the line-plot
                                # plotly visualizations
                                
                                output$plt_lines = plotly::renderPlotly(expr = {
                                  plt_res$line_plot
                                })
                                
                                output$plt_barplot = plotly::renderPlotly(expr = {
                                  plt_res$bar_plot
                                })
                                
                                # Sentinel-2 cropped image
                                
                                pth_png = file.path('data/Sentinel_2ard_green_spaces', glue::glue("osm_ID_{select_row_dat$osm_id}_enum_{select_row_dat$enum}.tif"))
                                # print(file.exists(pth_png))
                                
                                img_s2 = suppressWarnings(OpenImageR::readImage(path = pth_png))
                                img_s2 = OpenImageR::NormalizeObject(img_s2)
                                
                                tmp_png = tempfile(fileext = '.png')
                                OpenImageR::writeImage(data = img_s2, file_name = tmp_png)
                                
                                output$s2_img = shiny::renderImage({
                                  list(src = tmp_png,
                                       width = "100%",
                                       height = "450px",
                                       contentType = 'image/png',
                                       alt = "This is alternate text")
                                }, deleteFile = FALSE)
                                
                                
                                # Leaflet High resolution Image (using 'Esri.WorldImagery')
                                
                                lft_bbx = leaflet_bbox(sf_obj = select_row_dat$geometry,
                                                       leaflet_provider = leaflet::providers$Esri.WorldImagery,
                                                       opacity = 1.0,
                                                       popup = NULL,
                                                       option_viewer = rstudioapi::viewer)
                                
                                tmp_bbx = tempfile(fileext = '.png')
                                
                                mapview::mapshot(x = lft_bbx, 
                                                 vwidth = 450,
                                                 vheight = 450,
                                                 zoom = 1,
                                                 file = tmp_bbx)
                                
                                output$leafl_img = shiny::renderImage({
                                  list(src = tmp_bbx,
                                       width = "100%",
                                       height = "450px",
                                       contentType = 'image/png',
                                       alt = "This is alternate text")
                                }, deleteFile = FALSE)
                              }
                            }
                          }
                        })
  
  
  
  shiny::observeEvent(c(REACTIV$choosen_ROW,
                        REACTIV$VIZ_SUBS,
                        input$WKT), {
                          
                          if (shiny::isTruthy(REACTIV$choosen_ROW)) {
                            if (shiny::isTruthy(REACTIV$VIZ_SUBS)) {
                              if (shiny::isTruthy(input$WKT)) {
                                
                                select_row_dat = REACTIV$VIZ_SUBS[REACTIV$choosen_ROW, ]

                                # source location
                                
                                src_location = sf::st_as_sfc(x = as.character(input$WKT), crs = 4326)
                                src_location = suppressWarnings(sf::st_centroid(src_location))
                                src_location = sf::st_coordinates(src_location)
                                src_location = data.frame(src_location)
                                colnames(src_location) = c('lon', 'lat')
                                
                                # destination
                                
                                sf_obj = suppressWarnings(sf::st_centroid(select_row_dat$geometry))
                                sf_obj = sf::st_coordinates(sf_obj)
                                sf_obj = data.frame(sf_obj)
                                colnames(sf_obj) = c('lon', 'lat')
                                
                                # Route
                                
                                route = osrm::osrmRoute(src = src_location, 
                                                        dst = sf_obj,
                                                        overview = "full",
                                                        returnclass = "sf")
                                
                                
                                # Display Route
                                
                                route_view = mapview::mapview(x = route,
                                                              color = "red",
                                                              map.types = c('OpenStreetMap.Mapnik', 'Esri.WorldImagery'))
                                
                                output$route_map <- mapview::renderMapview({
                                  route_view
                                })
                                
                                # Show Distance and Time
                                
                                output$osm_distance = renderText({ as.character(round(route[1, ]$distance, 3)) })       # round by default to 3 digits and pick the first item in case that more than 1 are returned
                                output$osm_time = renderText({ as.character(round(route[1, ]$duration, 3)) })
                              }
                            }
                          }
                        })
  
  # shiny::observe({
  #   print("===========================")
  #   rvmap <- input$leaf_map_shape_click
  #   print(rvmap)
  #   print("---------------------------")
  #   rvmap_second <- input$leaf_map_pixel_shape_click
  #   print(rvmap_second)
  #   print("...........................")
  #   print(REACTIV$choosen_ROW)
  # })
  
})


