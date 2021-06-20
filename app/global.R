

# Requirements

require(shiny)
require(htmltools)
require(glue)
require(leaflet)
require(plotly)
require(data.table)
require(lubridate)
require(rayshader)
require(sf)
require(shinyjs)
require(DT)
require(mapview)
require(leafpop)
require(grDevices)
require(raster)
require(rgl)
require(OpenImageR)
require(rstudioapi)
require(osrm)


# global variables

remove_no_name_geoms = TRUE



# A helper function for popup-windows in shiny applications

popup_window_message = function(title,
                                message,
                                size = 'm',                                                                                        # by default set the size to 'medium'
                                title_attributes = list(font_family = 'times', font_size = 13,
                                                        font_style = 'italic', color = 'blue', text_align = 'center'),             # text-alignment:  'left', 'right', 'center'
                                message_attributes = list(font_family = 'times', font_size = 13,
                                                          font_style = 'italic', color = 'blue', text_align = 'left'),
                                easyClose = FALSE) {
  FOOTER = NULL
  if (easyClose) FOOTER = shiny::modalButton("Close")

  shiny::showModal(
    shiny::modalDialog(
      htmltools::HTML(glue::glue('<p style="text-align:{message_attributes$text_align}; font-family: {message_attributes$font_family}; font-size:{message_attributes$font_size}pt; font-style:{message_attributes$font_style}; color: {message_attributes$color}">{message}</p>')),
      title = htmltools::HTML(glue::glue('<p style="text-align:{title_attributes$text_align}; font-family: {title_attributes$font_family}; font-size:{title_attributes$font_size}pt; font-style:{title_attributes$font_style}; color: {title_attributes$color}">{title}</p>')),
      size = size,
      easyClose = easyClose,
      footer = FOOTER,
      fade = TRUE)
  )
}


# A helper function to reset the leaflet maps in shiny applications

clear_leaflet_console = function(mapID,
                                 Session,
                                 leaflet_provider) {
  lft_proxy = NULL
  lft_proxy = leaflet::leafletProxy(mapId = mapID, session = Session)
  lft_proxy = leaflet::clearMarkers(map = lft_proxy)
  lft_proxy = leaflet::clearControls(map = lft_proxy)
  lft_proxy = leaflet::clearPopups(map = lft_proxy)
  lft_proxy = leaflet::clearShapes(map = lft_proxy)

  lft_proxy = leaflet::setView(map = lft_proxy, lng = -30.234375, lat = 36.87962060502676, zoom = 1)
  lft_proxy = leaflet::addProviderTiles(map = lft_proxy, provider = leaflet_provider)
  
  return(lft_proxy)
}


# plotly lineplot for the time-series and barplot for the monthly data

plotly_admin_level_green_space = function(AOD_data, 
                                          admin_level_id,
                                          green_space_id,
                                          last_n_days = 30) {
  
  if (last_n_days < 1) stop("The 'last_n_days' parameter must be greater than 1!", call. = F)
  
  spl_admin = split(AOD_data, by = 'osm_id')
  
  dat_spl = lapply(spl_admin, function(x) {
    
    x = x[, .(aod_047 = mean(Optical_Depth_047, na.rm = T),
              osm_id = unique(osm_id)),
          by = 'date']
    x
  })
  
  subs_admin_lev = dat_spl[[admin_level_id]]
  subs_admin_lev = subs_admin_lev[order(subs_admin_lev$date, decreasing = T), ]
  
  idx_green_space = which(AOD_data$enum == green_space_id)
  subs_green_sp = AOD_data[idx_green_space, ]
  subs_green_sp = subs_green_sp[order(subs_green_sp$date, decreasing = T), ]
  
  fig <- plotly::plot_ly(data = subs_admin_lev[1:last_n_days, ], 
                         x = ~date, 
                         y = ~aod_047, 
                         type = 'scatter', 
                         mode = 'lines',
                         line = list(color = '#ffcc66', width = 5),
                         name = 'AOD_047 Admin Level')
  
  fig <- plotly::add_trace(p = fig, 
                           data = subs_green_sp[1:last_n_days, ], 
                           x = ~date, y = ~Optical_Depth_047, 
                           name = 'AOD_047 Green Space',
                           line = list(color = '#0000FF', width = 1))
  
  fig = plotly::layout(p = fig, 
                       yaxis = list(title = "<b>Aerosol Optical Depth (nm 047) per Day</b>"),
                       xaxis = list(title = '<b>Date</b>'), showlegend = TRUE) 
  
  # bar plot
  
  subs_admin_lev$year_month = as.character(glue::glue("{lubridate::month(subs_admin_lev$date)}_{lubridate::year(subs_admin_lev$date)}"))
  
  spl_ym = split(subs_admin_lev, by = 'year_month')
  nams_ym = names(spl_ym)
  spl_ym = as.vector(unlist(lapply(spl_ym, function(x) mean(x$aod_047, na.rm = T))))
  spl_ym_admin = data.table::setDT(list(year_month = nams_ym, admin_level_aod = spl_ym))
  spl_ym_admin
  
  subs_green_sp$year_month = as.character(glue::glue("{lubridate::month(subs_green_sp$date)}_{lubridate::year(subs_green_sp$date)}"))
  
  spl_ym = split(subs_green_sp, by = 'year_month')
  nams_ym = names(spl_ym)
  spl_ym = as.vector(unlist(lapply(spl_ym, function(x) mean(x$Optical_Depth_047, na.rm = T))))
  spl_ym_green_sp = data.table::setDT(list(year_month = nams_ym, green_space_aod = spl_ym))
  spl_ym_green_sp
  
  merg_dat = merge(spl_ym_admin, spl_ym_green_sp, by = 'year_month')
  dates_md = strsplit(merg_dat$year_month, '_')
  dates_md = data.frame(do.call(rbind, dates_md), stringsAsFactors = F)
  dates_md[, 1] = as.integer(dates_md[, 1])
  dates_md[, 2] = as.integer(dates_md[, 2])
  colnames(dates_md) = c('month', 'year')
  
  merg_dat = cbind(merg_dat, dates_md)
  merg_dat = merg_dat[order(merg_dat$year, merg_dat$month, decreasing = F), ]
  merg_dat$year_month = factor(merg_dat$year_month, levels = merg_dat$year_month)          # I have to sort the bars by year-month
  
  fig_barPLT <- plotly::plot_ly(data = merg_dat, x = merg_dat$year_month, y = merg_dat$admin_level_aod, type = 'bar', name = 'Admin Level AOD')
  fig_barPLT <- plotly::add_trace(p = fig_barPLT, data = merg_dat, y = merg_dat$green_space_aod, name = 'green spaces AOD')
  fig_barPLT <- plotly::layout(p = fig_barPLT, 
                               yaxis = list(title = "<b>Aerosol Optical Depth (nm 047) per Day</b>"), 
                               xaxis = list(title = '<b>YEAR-MONTH</b>'), barmode = 'group')
  
  return(list(line_plot = fig, bar_plot = fig_barPLT))
}


# rayshader 3-d adminstrative level

rayshader_3d_DEM = function(rst_buf,
                            zoom = 0.5,
                            windowsize = c(1600, 1000),
                            verbose = FALSE) {
  
  elevation_aoi = rayshader::raster_to_matrix(rst_buf, verbose = verbose)
  rayshade_3d = rayshader::sphere_shade(heightmap = elevation_aoi, zscale = 0.95, texture = "desert", progbar = verbose)
  rayshade_3d = rayshader::add_water(hillshade = rayshade_3d, watermap = rayshader::detect_water(elevation_aoi), color = "desert")
  rayshade_3d = rayshader::add_shadow(hillshade = rayshade_3d, rayshader::ray_shade(elevation_aoi, zscale = 3, maxsearch = 65), 0.5)
  
  rayshade_3d = tryCatch(rayshader::plot_3d(heightmap = elevation_aoi,
                                            hillshade = rayshade_3d,
                                            zoom = 0.5,
                                            zscale = 10,
                                            # fov = 0,
                                            # theta = 0,
                                            # phi = 1,
                                            windowsize = windowsize,
                                            water = TRUE,
                                            waterdepth = 0,
                                            wateralpha = 0.5,
                                            watercolor = "dodgerblue",
                                            waterlinecolor = "white",
                                            waterlinealpha = 0.3,
                                            verbose = verbose), error = function(e) e)
}



# crop a high resolution image by utilizing a Leaflet provider

leaflet_bbox = function(sf_obj,
                        leaflet_provider = leaflet::providers$Esri.WorldImagery,     # for an overview of leaflet-providers, SEE:  https://leaflet-extras.github.io/leaflet-providers/preview/
                        opacity = 1.0,
                        popup = NULL,
                        option_viewer = NULL) {                                      # or rstudioapi::viewer
  
  options(viewer = option_viewer)
  
  bbox_vec = sf::st_bbox(sf_obj)
  bbox_vec = as.vector(bbox_vec)
  
  leaflet_fitBounds_bbox = list(xmin = bbox_vec[1],
                                ymin = bbox_vec[2],
                                xmax = bbox_vec[3],
                                ymax = bbox_vec[4])
  
  lft = leaflet::leaflet()
  lft = leaflet::addProviderTiles(map = lft,
                                  provider = leaflet_provider)
  lft = leaflet::addPolygons(map = lft,
                             data = sf_obj,
                             color = 'purple',
                             opacity = opacity,
                             popup = popup)
  
  lft = leaflet::fitBounds(map = lft,
                           lng1 = leaflet_fitBounds_bbox$xmin,
                           lat1 = leaflet_fitBounds_bbox$ymin,
                           lng2 = leaflet_fitBounds_bbox$xmax,
                           lat2 = leaflet_fitBounds_bbox$ymax)
  
  return(lft)
}


