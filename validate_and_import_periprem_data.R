# ╔═══════╦═══════════════════════════════════════════════════════════╗
# ║ Title:║ PERIPrem validation and import                            ║
# ╠═══════╬═══════════════════════════════════════════════════════════╣
# ║  Desc:║ Validation and import of Acute Trust PERIPrem monthly     ║
# ║       ║ submissions                                               ║
# ╠═══════╬═══════════════════════════════════════════════════════════╣
# ║  Auth:║ Richard Blackwell                                         ║
# ╠═══════╬═══════════════════════════════════════════════════════════╣
# ║  Date:║ 2024-04-05                                                ║
# ╚═══════╩═══════════════════════════════════════════════════════════╝

# 0. Load libraries and define functions ----
# ───────────────────────────────────────────

library(tidyverse)
library(readxl)

fil_historic <- './input/PERIPrem_data.csv'
dir_input <- './input/updates'
dir_output <- './output'

source('periprem_reporting_functions.R')

fnProcessWorkbook <- function(filename, sheetname, org_code, dt_month, outdir){
  df <- read_excel(path = filename, 
                   sheet = sheetname,
                   col_names = FALSE) %>% 
    # Add Excel row number
    mutate(excel_row = as.integer(row.names(.)), .before = 1)
  
  # Extract data entry cells
  df <- df[10:NROW(df),1:(24+1)] %>% 
    rename_with(.fn = ~c('excel_row', 
                         'gestation', 'weight', 'births', 'ventilation', 'labour', 
                         'place', 
                         'steroids_rx', 'steroids_doses', 'steroids_opt_poss', 'steroids_opt_act', 
                         'mgso4_rx', 'mgso4_opt_poss', 'mgso4_opt_act', 
                         'antibiotics_rx', 'antibiotics_opt_poss', 'antibiotics_opt_act', 
                         'embm_info', 'cord_mgt', 'thermal_care', 'volume_guarantee', 
                         'caffeine', 'embm_rx', 'probiotics', 'hydrocortisone')) %>%
    filter(!is.na(gestation) & !is.na(weight) & !is.na(births)) %>%
    mutate(org_code = org_code, month = dt_month, .before = 1)
  
  # Perform validity checks
  df <- fnValidityChecks(df)
  
  # Calculate the optimisation metrics by birth
  df <- df %>% rowwise() %>% 
    mutate(
      eligible_intervention_rx_num = sum(across(.cols = c(10,11,15,18,22:28), .fn = function(x){x=='Yes'}), na.rm = TRUE),
      eligible_intervention_rx_dem = sum(across(.cols = c(10,11,15,18,22:28), .fn = function(x){!is.na(x)})),
      all_eligible_intervention_rx_num = (eligible_intervention_rx_num==eligible_intervention_rx_dem)*1,
      .after = 'hydrocortisone')
  
  # Return all the data along with valid flags
  return(df)
}

fnValidityChecks <- function(df){
  df <- df %>%
    mutate(
      check_gestation = fnCheck_gestation(.),
      check_weight = fnCheck_weight(.),
      check_births =fnCheck_births(.),
      check_ventilation =fnCheck_ventilation(.),
      check_labour =fnCheck_labour(.),
      check_place = fnCheck_place(.),
      check_steroids_rx = fnCheck_steroids_rx(.),
      check_steroids_doses = fnCheck_steroids_doses(.),
      check_steroids_opt_poss =fnCheck_steroids_opt_poss(.),
      check_steroids_opt_act = fnCheck_steroids_opt_act(.),
      check_mgso4_rx = fnCheck_mgso4_rx(.),
      check_mgso4_opt_poss = fnCheck_mgso4_opt_poss(.),
      check_mgso4_opt_act = fnCheck_mgso4_opt_act(.),
      check_antibiotics_rx = fnCheck_antibiotics_rx(.),
      check_antibiotics_opt_poss = fnCheck_antibiotics_opt_poss(.),
      check_antibiotics_opt_act = fnCheck_antibiotics_opt_act(.),
      # NB: Early Maternal Breast Milk information not currently validated
      # check_embm_info = fnCheck_embm_info(.),
      check_cord_mgt = fnCheck_cord_mgt(.),
      check_thermal_care = fnCheck_thermal_care(.),
      check_volume_guarantee = fnCheck_volume_guarantee(.),
      check_caffeine = fnCheck_caffeine(.),
      check_embm_rx = fnCheck_embm_rx(.),
      check_probiotics = fnCheck_probiotics(.),
      check_hydrocortisone = fnCheck_hydrocortisone(.)) %>%
    mutate(
      check_overall = check_gestation & check_weight & 
        check_births & check_ventilation & check_labour & 
        check_place & check_steroids_rx & check_steroids_doses & 
        check_steroids_opt_poss & check_steroids_opt_act & check_mgso4_rx & 
        check_mgso4_opt_poss & check_mgso4_opt_act & check_antibiotics_rx & 
        check_antibiotics_opt_poss & check_antibiotics_opt_act & 
        # NB: Early Maternal Breast Milk information not currently validated
        # check_embm_info & 
        check_cord_mgt & check_thermal_care & check_volume_guarantee & 
        check_caffeine & check_embm_rx & check_probiotics & 
        check_hydrocortisone,
      .after = 1)  
  return(df)
}

# 1. Load historic data  ----
# ───────────────────────────

df_historic <- read.csv(fil_historic) %>%
  mutate(month = as.Date(month, tryFormats = c('%Y-%m-%d', '%d/%m/%Y')))

# 2. Validate and process current data ----
# ─────────────────────────────────────────

# Create output folder if it doesn't already exist
outdir <- dir_output
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

# Create the process log file
fil_process_log <- file(paste0('./', outdir, '/process.log'), open = 'wt')
writeLines(sprintf('org_code, valid_lines, invalid_lines'), fil_process_log)

# Get a list of the input files in the input directory
files <- list.files(path = dir_input, pattern = '.xlsx$', full.names = TRUE)

# Set up a blank data frame for the results
df_combined <- data.frame()

# Iterate through the list of file in the input directory
for(f in files){

  # The org_code and month will be extracted from the filename
  # this means the structure of the filename is crucial it should *always* be in the format
  # MMM YYYY - TTT[T].xlsx
  # e.g. "JUN 2024 - RDUE.xlsx" or "SEP 2024 - TOR.xlsx"

  # Extract trust from filename
  org_code <- gsub('.xlsx', '', str_sub(basename(f), start = 12))
  
  # Extract month from filename
  dt_month <- as.Date(paste0('01', str_sub(basename(f), start = 1, end = 8)), format = '%d %b %Y')
  
  df_cleaned <- fnProcessWorkbook(filename = f,
                                  sheetname = 'Tab 2 Data ONLY EDIT THIS TAB',
                                  org_code,
                                  dt_month,
                                  outdir = 'output')
  # Create the error output filename
  fil_errors <- paste0('./', outdir, '/', org_code, toupper(format(df_cleaned$month[1], '_%b_%Y_ERR.csv')))
  
  # Create the error data frame 
  df_errors <- df_cleaned %>% 
    dplyr::select(c(org_code, month, excel_row), starts_with('check_')) %>% 
    dplyr::select(-check_overall) %>%
    pivot_longer(cols = c(4:NCOL(.)), names_to = 'validation_check_failed', values_to = 'validity') %>%
    filter(validity == FALSE) %>%
    dplyr::select(-validity)

  writeLines(sprintf('%s, %s, %d, %d', 
                     toupper(format(dt_month, '%b %y')),
                     org_code, 
                     df_cleaned %>% filter(check_overall==TRUE) %>% NROW(),
                     df_cleaned %>% filter(check_overall==FALSE) %>% NROW()),fil_process_log)
  
  # If there are any errors write them to the error file for the Acute Trust
  if(NROW(df_errors>0))
    write.csv(df_errors, fil_errors, row.names = FALSE)
  
  # Add the processed data to the overall data frame
  df_combined <- df_combined %>% bind_rows(df_cleaned)
}
close(fil_process_log)

# Create the actual grouped data output to combine with the historic data
df_output <- df_combined %>% 
  filter(check_overall == TRUE) %>%
  group_by(org_code, month) %>%
  summarise(
    # Number of Babies
    babies = n(),
    # Right Place
    place_num = sum(place=='Yes', na.rm = TRUE),
    place_dem = sum(!is.na(place)),
    # Steroids Rx
    steroids_rx_num = sum(steroids_rx=='Yes', na.rm = TRUE),
    steroids_rx_dem = sum(!is.na(steroids_rx)),
    # Steroids Optimisation Possible
    steroids_opt_poss_num = sum(steroids_opt_poss=='Yes', na.rm = TRUE),
    steroids_opt_poss_dem = sum(!is.na(steroids_opt_poss)),
    # Steroids Optimisation Achieved
    steroids_opt_act_num = sum(steroids_opt_act=='Yes', na.rm = TRUE),
    steroids_opt_act_dem = sum(!is.na(steroids_opt_act)),
    # MgSO4 Rx
    mgso4_rx_num = sum(mgso4_rx=='Yes', na.rm = TRUE),
    mgso4_rx_dem = sum(!is.na(mgso4_rx)),
    # MgSO4 Optimisation Possible
    mgso4_opt_poss_num = sum(mgso4_opt_poss=='Yes', na.rm = TRUE),
    mgso4_opt_poss_dem = sum(!is.na(mgso4_opt_poss)),
    # MgSO4 Optimisation Achieved
    mgso4_opt_act_num = sum(mgso4_opt_act=='Yes', na.rm = TRUE),
    mgso4_opt_act_dem = sum(!is.na(mgso4_opt_act)),
    # Antibiotics Rx
    antibiotics_rx_num = sum(antibiotics_rx=='Yes', na.rm = TRUE),
    antibiotics_rx_dem = sum(!is.na(antibiotics_rx)),
    # Antibiotics Optimisation Possible
    antibiotics_opt_poss_num = sum(antibiotics_opt_poss=='Yes', na.rm = TRUE),
    antibiotics_opt_poss_dem = sum(!is.na(antibiotics_opt_poss)),
    # Antibiotics Optimisation Achieved
    antibiotics_opt_act_num = sum(antibiotics_opt_act=='Yes', na.rm = TRUE),
    antibiotics_opt_act_dem = sum(!is.na(antibiotics_opt_act)),
    # Cord Management
    cord_mgt_num = sum(cord_mgt=='Yes', na.rm = TRUE),
    cord_mgt_dem = sum(!is.na(cord_mgt)),
    # Thermal Care
    thermal_care_num = sum(thermal_care=='Yes', na.rm = TRUE),
    thermal_care_dem = sum(!is.na(thermal_care)),
    # Ventilation VGTV/VG
    volume_guarantee_num = sum(volume_guarantee=='Yes', na.rm = TRUE),
    volume_guarantee_dem = sum(!is.na(volume_guarantee)),
    # Caffeine
    caffeine_num = sum(caffeine=='Yes', na.rm = TRUE),
    caffeine_dem = sum(!is.na(caffeine)),
    # Early Maternal Breast Milk
    embm_rx_num = sum(embm_rx=='Yes', na.rm = TRUE),
    embm_rx_dem = sum(!is.na(embm_rx)),
    # Probiotics
    probiotics_num = sum(probiotics=='Yes', na.rm = TRUE),
    probiotics_dem = sum(!is.na(probiotics)),
    # Hydrocortisone
    hydrocortisone_num = sum(hydrocortisone=='Yes', na.rm = TRUE),
    hydrocortisone_dem = sum(!is.na(hydrocortisone)),
    # Elibible interventions
    eligible_intervention_rx_num = sum(eligible_intervention_rx_num, na.rm = TRUE),
    eligible_intervention_rx_dem = sum(eligible_intervention_rx_dem, na.rm = TRUE),
    all_eligible_intervention_rx_num = sum(all_eligible_intervention_rx_num, na.rm = TRUE),
    all_eligible_intervention_rx_dem = babies,
    .groups = 'keep'
  ) %>% 
  ungroup()

# 3. Delete existing data from historic data ----
# ───────────────────────────────────────────────
df_historic <- df_historic %>% 
  anti_join(df_output %>% distinct(org_code, month),
            by = c('org_code', 'month'))

# 4. Add the current data to the historic data ----
# ─────────────────────────────────────────────────
df_historic <- df_historic %>% 
  bind_rows(df_output) %>%
  arrange(org_code, month)

fil_historic <- paste0('./', outdir, '/PERIPrem_data.csv')
write.csv(df_historic, fil_historic, row.names = FALSE)

stop()

# 5. Validate and process current data ----
# ─────────────────────────────────────────

f <- './temp/MAY 2023 -YEO.xlsx'
org_code <- 'YEO'
dt_month <- as.Date('2023-05-01')
output <- './temp'
df_cleaned <- fnProcessWorkbook(filename = f,
                                sheetname = 'Tab 2 Data ONLY EDIT THIS TAB',
                                org_code,
                                dt_month,
                                outdir = output)

# Create the error data frame 
df_errors <- df_cleaned %>% 
  dplyr::select(c(org_code, month, excel_row), starts_with('check_')) %>% 
  dplyr::select(-check_overall) %>%
  pivot_longer(cols = c(4:NCOL(.)), names_to = 'validation_check_failed', values_to = 'validity') %>%
  filter(validity == FALSE) %>%
  dplyr::select(-validity)

df_output <- df_cleaned %>% 
  filter(check_overall == TRUE) %>%
  group_by(org_code, month) %>%
  summarise(
    # Number of Babies
    babies = n(),
    # Right Place
    place_num = sum(place=='Yes', na.rm = TRUE),
    place_dem = sum(!is.na(place)),
    # Steroids Rx
    steroids_rx_num = sum(steroids_rx=='Yes', na.rm = TRUE),
    steroids_rx_dem = sum(!is.na(steroids_rx)),
    # Steroids Optimisation Possible
    steroids_opt_poss_num = sum(steroids_opt_poss=='Yes', na.rm = TRUE),
    steroids_opt_poss_dem = sum(!is.na(steroids_opt_poss)),
    # Steroids Optimisation Achieved
    steroids_opt_act_num = sum(steroids_opt_act=='Yes', na.rm = TRUE),
    steroids_opt_act_dem = sum(!is.na(steroids_opt_act)),
    # MgSO4 Rx
    mgso4_rx_num = sum(mgso4_rx=='Yes', na.rm = TRUE),
    mgso4_rx_dem = sum(!is.na(mgso4_rx)),
    # MgSO4 Optimisation Possible
    mgso4_opt_poss_num = sum(mgso4_opt_poss=='Yes', na.rm = TRUE),
    mgso4_opt_poss_dem = sum(!is.na(mgso4_opt_poss)),
    # MgSO4 Optimisation Achieved
    mgso4_opt_act_num = sum(mgso4_opt_act=='Yes', na.rm = TRUE),
    mgso4_opt_act_dem = sum(!is.na(mgso4_opt_act)),
    # Antibiotics Rx
    antibiotics_rx_num = sum(antibiotics_rx=='Yes', na.rm = TRUE),
    antibiotics_rx_dem = sum(!is.na(antibiotics_rx)),
    # Antibiotics Optimisation Possible
    antibiotics_opt_poss_num = sum(antibiotics_opt_poss=='Yes', na.rm = TRUE),
    antibiotics_opt_poss_dem = sum(!is.na(antibiotics_opt_poss)),
    # Antibiotics Optimisation Achieved
    antibiotics_opt_act_num = sum(antibiotics_opt_act=='Yes', na.rm = TRUE),
    antibiotics_opt_act_dem = sum(!is.na(antibiotics_opt_act)),
    # Cord Management
    cord_mgt_num = sum(cord_mgt=='Yes', na.rm = TRUE),
    cord_mgt_dem = sum(!is.na(cord_mgt)),
    # Thermal Care
    thermal_care_num = sum(thermal_care=='Yes', na.rm = TRUE),
    thermal_care_dem = sum(!is.na(thermal_care)),
    # Ventilation VGTV/VG
    volume_guarantee_num = sum(volume_guarantee=='Yes', na.rm = TRUE),
    volume_guarantee_dem = sum(!is.na(volume_guarantee)),
    # Caffeine
    caffeine_num = sum(caffeine=='Yes', na.rm = TRUE),
    caffeine_dem = sum(!is.na(caffeine)),
    # Early Maternal Breast Milk
    embm_rx_num = sum(embm_rx=='Yes', na.rm = TRUE),
    embm_rx_dem = sum(!is.na(embm_rx)),
    # Probiotics
    probiotics_num = sum(probiotics=='Yes', na.rm = TRUE),
    probiotics_dem = sum(!is.na(probiotics)),
    # Hydrocortisone
    hydrocortisone_num = sum(hydrocortisone=='Yes', na.rm = TRUE),
    hydrocortisone_dem = sum(!is.na(hydrocortisone)),
    # Elibible interventions
    eligible_intervention_rx_num = sum(eligible_intervention_rx_num, na.rm = TRUE),
    eligible_intervention_rx_dem = sum(eligible_intervention_rx_dem, na.rm = TRUE),
    all_eligible_intervention_rx_num = sum(all_eligible_intervention_rx_num, na.rm = TRUE),
    all_eligible_intervention_rx_dem = babies,
    .groups = 'keep'
  ) %>% 
  ungroup()

write.csv(df_cleaned, paste0(output, '/cleaned_', toupper(format(dt_month, '%b %Y')),'.csv'), row.names = FALSE)
write.csv(df_errors, paste0(output, '/errors', toupper(format(dt_month, '%b %Y')),'.csv'), row.names = FALSE)
write.csv(df_output, paste0(output, '/output', toupper(format(dt_month, '%b %Y')),'.csv'), row.names = FALSE)


