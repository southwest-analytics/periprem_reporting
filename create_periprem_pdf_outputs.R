  # ╔═══════╦═══════════════════════════════════════════════════════════╗
  # ║ Title:║ PERIPrem PDF creation                                     ║
  # ╠═══════╬═══════════════════════════════════════════════════════════╣
  # ║  Desc:║ Creation of PERIPrem monthly PDF outputs for Acute Trusts ║
  # ║       ║ ICBs and Regions                                          ║
  # ╠═══════╬═══════════════════════════════════════════════════════════╣
  # ║  Auth:║ Richard Blackwell                                         ║
  # ╠═══════╬═══════════════════════════════════════════════════════════╣
  # ║  Date:║ 2024-04-05                                                ║
  # ╚═══════╩═══════════════════════════════════════════════════════════╝
  
  # 0. Load libraries and define functions ----
  # ───────────────────────────────────────────
  
  library(tidyverse)
  library(raster)
  library(readxl)
  library(grid)
  library(magick)
  library(ggspatial)
  library(prettymapr)
  library(sf)
  library(ggrepel)
  library(scales)
  library(sisal)
  library(gridExtra)
  library(pdftools)
  library(ini)
  
  fnCreateLinePlot <- function(df_plotdata, plot_title, xaxis, yaxis, target = NULL){
    df_plotdata <- df_plotdata %>% 
      mutate(pct = rx/(dnrx+rx))
    plt_line <- ggplot(df_plotdata) %+%
      theme_bw(base_size = 12) %+%
      theme(plot.title = element_text(hjust = 0.5),
            axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) %+%
      labs(#title = str_wrap(plot_title, width = 60),
           x = xaxis,
           y = yaxis)
    if(!is.null(target)){
      plt_line <- plt_line %+%
        geom_hline(aes(yintercept = target), colour = '#d95f02', linetype = 'dashed', linewidth = 0.75) %+%
        geom_label(aes(x = min(month, na.rm = TRUE), y = target, label = 'Target'), vjust = 0.5, colour = '#d95f02')
    }
    plt_line <- plt_line %+%
      geom_line(aes(x = month, y = pct), colour = '#1b9e77', linewidth = 1) %+%
      geom_point(aes(x = month, y = pct), shape = 21, size = 3, stroke = 1,
                 colour = '#1b9e77', fill = 'white') %+%
      scale_x_date(date_breaks = '3 months', minor_breaks = NULL, date_labels = '%b-%y') %+%
      scale_y_continuous(labels = scales::percent, limits = c(0,1))
    return(plt_line)
  }
  
  fnCreateBarPlot <- function(df_plotdata, plot_title, xaxis, yaxis){
    df_plotdata <- df_plotdata %>%
      pivot_longer(cols = c('rx','dnrx'), 
                   names_to = 'metric', 
                   values_to = 'value')
    
    plt_bar <- ggplot(df_plotdata) %+%
      theme_bw(base_size = 12) %+%
      theme(plot.title = element_text(hjust = 0.5),
            axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
            legend.position = 'bottom') %+%
      labs(#title = str_wrap(plot_title, width = 60),
           x = xaxis, y = yaxis) %+%
      geom_bar(aes(x = month, y = value, group = metric, fill = metric), stat = 'identity', position = 'stack') %+%
      scale_fill_manual(values = c('dnrx' = '#d95f02', 'rx' = '#1b9e77'),
                        labels = c('dnrx' = 'Did Not Receive', 'rx' = 'Received'),
                        name = 'Receipt of Intervention') %+%
      scale_x_date(date_breaks = '3 months', minor_breaks = NULL, date_labels = '%b-%y') %+%
      scale_y_continuous(labels = as.integer, 
                         breaks = pretty(x = df_plotdata %>% group_by(month) %>% summarise(value =sum(value)) %>% .$value, n = 5))
    return(plt_bar)
  }
  
  fnProcessOrganisation <- function(df_subset, org_code, org_name, member_org_list, dt_month){
    # 1. Open the PDF device
    outfile <- paste0(ini_settings$Outputs$dir, '/', org, '_', format(dt_month, '%Y%m%d'), '.pdf')
    pdf(file = outfile, paper = 'a4r', width = 11.69, height = 8.27)
    
    # 2. Create location map
    map <- fnCreateLocationMap(org_code, org_name, member_org_list)
    grid.draw(map)
    
    # 3. Create the infographic
    fnCreateInfographic(df_subset, org_code, org_name, dt_month)
  
    # 4. Create baby count
    fnCreateCount(baby_count = sum(df_subset$babies))
  
    # 5. Bundle score graphs
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = all_eligible_intervention_rx_num,
             dnrx = all_eligible_intervention_rx_dem - all_eligible_intervention_rx_num)
    plot_title <- 'PERIPrem Bundle Optimisation: How many mothers and babies received ALL the intervention for which they were eligible?'
    xaxis <- 'Month'
    yaxis_line <- 'PERIPrem Bundle Optimisation'
    yaxis_bar <- 'Number of Mothers|Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar, target = 0.7)
  
    # 6. Optimisation score graphs
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = eligible_intervention_rx_num,
             dnrx = eligible_intervention_rx_dem - eligible_intervention_rx_num)
    plot_title <- 'PERIPrem Bundle: Optimisation Score [Total number of interventions given / total number of optimal interventions]'
    xaxis <- 'Month'
    yaxis_line <- 'Optimisation Score'
    yaxis_bar <- 'Number of Interventions'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar, target = 1.0)
    
    # 7. Create place of birth graphs
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = place_num,
             dnrx = place_dem - place_num)
    plot_title <- 'How many babies did we ensure were born in the right place?'
    xaxis <- 'Month'
    yaxis_line <- 'Born in the Right Place'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 8. Steroids
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = steroids_rx_num,
             dnrx = steroids_rx_dem - steroids_rx_num)
    plot_title <- "How many babies' mothers received ANY antenatal steroids?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Antenatal Steroids'
    yaxis_bar <- 'Number of Mothers'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 9. Steroids Optimal
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = steroids_opt_act_num,
             dnrx = steroids_opt_act_dem - steroids_opt_act_num)
    plot_title <- "How many babies' mothers were administered antenatal steroids OPTIMALLY?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Antenatal Steroids Optimally'
    yaxis_bar <- 'Number of Mothers'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 10. MgSO4
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = mgso4_rx_num,
             dnrx = mgso4_rx_dem - mgso4_rx_num)
    plot_title <- "How many babies' mothers received ANY magnesium sulphate?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Magnesium Sulphate'
    yaxis_bar <- 'Number of Mothers'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 11. MgSO4 Optimal
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = mgso4_opt_act_num,
             dnrx = mgso4_opt_act_dem - mgso4_opt_act_num)
    plot_title <- "How many babies' mothers were administered magnesium sulphate OPTIMALLY?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Magnesium Sulphate Optimally'
    yaxis_bar <- 'Number of Mothers'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
  
    # 12. Antibiotics
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = antibiotics_rx_num,
             dnrx = antibiotics_rx_dem - antibiotics_rx_num)
    plot_title <- "How many babies' mothers received ANY intrapartum antibiotics?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Intrapartum Antibiotics'
    yaxis_bar <- 'Number of Mothers'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 13. Antibiotics Optimal
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = antibiotics_opt_act_num,
             dnrx = antibiotics_opt_act_dem - antibiotics_opt_act_num)
    plot_title <- "How many babies' mothers were administered intrapartum antibiotics OPTIMALLY?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Intrapartum Antibiotics Optimally'
    yaxis_bar <- 'Number of Mothers'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
  
    # 14. Cord Management
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = cord_mgt_num,
             dnrx = cord_mgt_dem - cord_mgt_num)
    plot_title <- "How many babies benefited from optimal cord management?"
    xaxis <- 'Month'
    yaxis_line <- 'Benefited from Optimal Cord Management'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 15. Thermal Care
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = thermal_care_num,
             dnrx = thermal_care_dem - thermal_care_num)
    plot_title <- "How many babies had a normothermic temperature (36.5 to 37.5°C) measured within one hour of admission to the neonatal unit?"
    xaxis <- 'Month'
    yaxis_line <- 'Normothermic Temperature Measured'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 16. Volume Guarantee
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = volume_guarantee_num,
             dnrx = volume_guarantee_dem - volume_guarantee_num)
    plot_title <- "For babies that required ventilation, how many were ventilated using a VTV/VG mode?"
    xaxis <- 'Month'
    yaxis_line <- 'Ventilated using VTV/VG Mode'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 17. Caffeine
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = caffeine_num,
             dnrx = caffeine_dem - caffeine_num)
    plot_title <- "How many babies received caffeine (preferably within 6 hours of birth)?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Caffeine'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 18. Early Maternal Breast Milk
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = embm_rx_num,
             dnrx = embm_rx_dem - embm_rx_num)
    plot_title <- "How many babies received early maternal breast milk within 6 hours of birth?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Early Maternal Breast Milk'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 19. Probiotics
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = probiotics_num,
             dnrx = probiotics_dem - probiotics_num)
    plot_title <- "How many babies received a multi strain probiotic on the first day of life?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Multi Strain Probiotic'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
    
    # 20. Hydrocortisone
    df_plotdata <- df_subset %>% 
      mutate(month, 
             rx = hydrocortisone_num,
             dnrx = hydrocortisone_dem - hydrocortisone_num)
    plot_title <- "How many babies received prophylactic hydrocortisone from day 0 of life?"
    xaxis <- 'Month'
    yaxis_line <- 'Received Prophylactic Hydrocortisone'
    yaxis_bar <- 'Number of Babies'
    fnCreateGraphPage(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar)
  
    dev.off()
  }
  
  fnCreateLocationMap <- function(org_code, org_name, member_org_list){
    # Subset the location data to just the member organisations
    sf_trusts <- st_as_sf(
      df_locations %>% 
        filter(ORG %in% member_org_list) %>%
        mutate(X = LNG, Y = LAT), 
      coords = c('X','Y'), 
      dim = 'XY', 
      crs = 4326)
    # Get the bounding box from the ini file settings for use as limits of the map
    bbox <- eval(parse(text = eval(parse(text = paste0('ini_settings$', org, '$bbox')))))
  
    # Create the map
    map <- ggplot() %+%
      theme_void(base_size = 12) %+%
      theme(plot.title = element_text(hjust = 0.5, color = '#1b9e77')) %+%
      labs(title = paste0('Organisation Locations for ', org_name, '\n')) %+%
      annotation_map_tile(type = 'osm', cachedir = 'maps/', zoomin = 0) %+%
      geom_sf(data = sf_trusts, color = '#1b9e77', fill = 'white', shape = 21, size = 3, stroke = 2.5) %+%
      geom_label_repel(data = sf_trusts, 
                       aes(x = LNG, y = LAT, label = str_wrap(ORG_NAME, 30)), 
                       size = 4, box.padding = .5, color = '#1b9e77') %+%
      coord_sf(
        xlim = c(bbox[1], bbox[3]), 
        ylim = c(bbox[2], bbox[4]),
        crs = 4326) # EPSG code for WGS84)
    # Return the map
    return(map)
  }
  
  fnCreateInfographic <- function(df_subset, org_code, org_name, dt_month){
    # Calculate scores
    df_plotdata <- df_subset %>% 
      filter(month == dt_month) %>% 
      mutate(bundle_score = all_eligible_intervention_rx_num/ all_eligible_intervention_rx_dem,
             optimisation_score = eligible_intervention_rx_num/ eligible_intervention_rx_dem,
             babies,
             .keep = 'none')
  
    # Load the PERIPrem infographic image
    img <- image_read_pdf(path = ini_settings$Inputs$infographic, pages = 1, density = 300)
    img <- magick::image_resize(img, geometry_size_percent(84, 84))
    
    # Set Viewports
    vp_trust <- viewport(x = unit(13, 'mm'), y = unit(144, 'mm'), 
                         width = unit(180, 'mm'), height = unit(23, 'mm'), 
                         just = c('left','bottom'),
                         gp = gpar(fontsize = 40, fontface = 'bold', col = '#A666AA'))
    
    vp_month <- viewport(x = unit(13, 'mm'), y = unit(123, 'mm'), 
                         width = unit(180, 'mm'), height = unit(15, 'mm'), 
                         just = c('left','bottom'),
                         gp = gpar(fontsize = 40, fontface = 'bold', col = '#A666AA'))
    
    vp_bundle_score <- viewport(x = unit(34, 'mm'), y = unit(48, 'mm'), 
                                width = unit(34, 'mm'), height = unit(17, 'mm'), 
                                just = c('left','bottom'),
                                gp = gpar(fontsize = 40, fontface = 'bold', col = 'white'))
    
    vp_optimisation_score <- viewport(x = unit(125, 'mm'), y = unit(48, 'mm'), 
                                      width = unit(34, 'mm'), height = unit(17, 'mm'), 
                                      just = c('left','bottom'),
                                      gp = gpar(fontsize = 40, fontface = 'bold', col = 'white'))
    
    vp_eligible_babies <- viewport(x = unit(216, 'mm'), y = unit(48, 'mm'), 
                                   width = unit(34, 'mm'), height = unit(17, 'mm'), 
                                   just = c('left','bottom'),
                                   gp = gpar(fontsize = 40, fontface = 'bold', col = 'white'))
    
    # Set Text
    txt_trust <- dynTextGrob(label = str_wrap(org_name, ceiling(nchar(org_name)/1.5)), x = 0.5, y = 0.5, just = c('centre', 'centre'))
    txt_month <- dynTextGrob(label = format(dt_month, '%B %Y') , x = 0.5, y = 0.5, just = c('centre', 'centre'))
    txt_bundle_score <- dynTextGrob(label = sprintf('%.0f%%', df_plotdata$bundle_score * 100), x = 0.5, y = 0.5, just = c('centre', 'centre'))
    txt_optimisation_score <- dynTextGrob(label = sprintf('%.0f%%', df_plotdata$optimisation_score * 100), x = 0.5, y = 0.5, just = c('centre', 'centre'))
    txt_eligible_babies <- dynTextGrob(label = sprintf('%d', df_plotdata$babies), x = 0.5, y = 0.5, just = c('centre', 'centre'))
  
    # Force a new page after the map
    grid.newpage()
    
    # Plot the pdf inforgraphic background
    grid.raster(img)
    
    # Write to the Trust Name viewport
    pushViewport(vp_trust)
    grid.draw(txt_trust)
    popViewport()
    
    # Write to the Month viewport
    pushViewport(vp_month)
    grid.draw(txt_month)
    popViewport()
    
    # Write to the Bundle Score viewport
    pushViewport(vp_bundle_score)
    grid.draw(txt_bundle_score)
    popViewport()
    
    # Write to the Optimisation Score viewport
    pushViewport(vp_optimisation_score)
    grid.draw(txt_optimisation_score)
    popViewport()
    
    # Write to the Eligible Babies viewport
    pushViewport(vp_eligible_babies)
    grid.draw(txt_eligible_babies)
    popViewport()
  }
  
  fnCreateCount <- function(baby_count){
    grid.newpage()
    vp_title <- viewport(x = unit(0, 'mm'), y = unit(195, 'mm'), 
                         width = unit(285, 'mm'), height = unit(30, 'mm'),
                         just = c('left','top'))
    vp_value <- viewport(x = unit(142, 'mm'), y = unit(98, 'mm'), 
                         width = unit(60, 'mm'), height = unit(60, 'mm'),
                         just = c('centre','centre'))
    txt_title <- dynTextGrob(label = 'Number of Mothers and Babies Eligible for PERIPrem',
                             x = 0.5, y = 0.5, just = c('centre', 'centre'),
                             gp = gpar(fontsize = 40, fontface = 'bold'))
    txt_value <- dynTextGrob(label = baby_count,
                             x = 0.5, y = 0.5, just = c('centre', 'centre'),
                             gp = gpar(fontsize = 40, fontface = 'bold', col = '#A666AA'))
  
    pushViewport(vp_title)
    grid.draw(txt_title)
    popViewport()
    
    pushViewport(vp_value)
    grid.draw(txt_value)
    popViewport()
  }
  
  fnCreateGraphPage <- function(df_plotdata, plot_title, xaxis, yaxis_line, yaxis_bar, target = NULL){
    grid.newpage()
    vp_title <- viewport(x = unit(0, 'mm'), y = unit(196, 'mm'),
                         width = unit(285, 'mm'), height = unit(20, 'mm'),
                         just = c('left','top'))
    vp_graphs <- viewport(x = unit(0, 'mm'), y = unit(0, 'mm'),
                          width = unit(285, 'mm'), height = unit(176, 'mm'),
                          just = c('left','bottom'))
  
    txt_title <- dynTextGrob(label = str_wrap(plot_title, 80), x = 0, y = 0.5, 
                             just = c('left', 'centre'),
                             gp = gpar(fontsize = 40, fontface = 'bold'))
    
    plt_line <- fnCreateLinePlot(df_plotdata, plot_title, xaxis, yaxis_line, target)
    plt_bar <- fnCreateBarPlot(df_plotdata, plot_title, xaxis, yaxis_bar)
  
    graphs <- arrangeGrob(grobs = list(plt_line, plt_bar), vp = vp_graphs, nrow = 2)  
    grid.draw(graphs)
    
    pushViewport(vp_title)
    grid.draw(txt_title)
    popViewport()
  }
  
  # 1. Load ini file settings and reference data  ----
  # ──────────────────────────────────────────────────
  dt_start <- Sys.time()
  
  # * 1.1. Load ini file settings ----
  ini_settings <- read.ini('create_periprem_pdf_outputs.ini')
  
  # Create output directory if it doesn't exist
  dir.create(ini_settings$Outputs$dir, 
             showWarnings = FALSE, 
             recursive = TRUE)
  
  # Get the reporting month
  dt_month = as.Date(ini_settings$Inputs$month, format = '%Y-%m-%d')
  
  # * 1.2. Load location data ----
  df_locations <- read.csv(ini_settings$Inputs$locations)
  
  # * 1.3. Load PERIPrem data ----
  df_data <- read.csv(ini_settings$Inputs$data) %>%
    mutate(month = as.Date(month, tryFormats = c('%Y-%m-%d','%d/%m/%Y')))
  
  # 2. Process organisation group list ----
  org_list <- eval(parse(text = ini_settings$Outputs$codes))
  
  # Step through each organisation
  for(org in org_list){
    # Get the name for the plot titles etc
    org_name <- eval(parse(text = paste0('ini_settings$', org, '$name')))
    # Get the member organisation list for this organisation
    member_org_list <- eval(parse(text = eval(parse(text = paste0('ini_settings$', org, '$codes')))))
  
    # Subset the data, group and summarise
    df_subset <- df_data %>% 
      filter(org_code %in% member_org_list &
               month <= dt_month) %>%
      dplyr::select(-org_code) %>%
      group_by(month) %>%
      summarise(across(everything(), .fns = \(x) sum(x, na.rm = TRUE))) %>%
      ungroup()
    
    # Pass this data to the main process function
    df_subset = df_subset
    org_code = org
    org_name = org_name
    member_org_list = member_org_list
  
    if(df_subset %>% filter(month == dt_month) %>% NROW!=0){
      # Only run the processing of the organisation if a row for the current month is present  
      fnProcessOrganisation(df_subset, org_code, org_name, member_org_list, dt_month)
    } else {
      # Otherwise find the latest months data for that organisation and run that month
      fnProcessOrganisation(df_subset, org_code, org_name, member_org_list, max(df_subset$month))
    }
  }
  
  dt_end <- Sys.time()
  difftime(dt_end, dt_start)
