# 0. Load libraries and define functions ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(tidyverse)
library(readxl)

# 1. Read input worksheet ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Read in entire sheet
df <- read_excel(path = './input/Example_Data.xlsx', 
                 sheet = 'Tab 2 Data ONLY EDIT THIS TAB',
                 col_names = FALSE)

# Extract trust name (Cell H3)
trust_name <- df[3, 8]

# Extract perinatal leads (Cell P3)
perinatal_leads <- df[3, 16]

# Extract data entry cells
df <- df[10:NROW(df),1:24] %>% 
  rename_with(.fn = ~c('gestation', 'weight', 'births', 'ventilation', 'active_labour', 
                       'place', 'antenatal_steroid_receipt', 'antenatal_steroid_doses', 'antenatal_steroid_optimal_pos', 'antenatal_steroid_optimal_act', 
                       'antenatal_MgSO4_receipt', 'antenatal_MgSO4_optimal_pos', 'antenatal_MgSO4_optimal_act', 
                       'intrapartum_antibiotics', 'intrapartum_antibiotics_optimal_pos', 'intrapartum_antibiotics_optimal_act', 
                       'embm_information', 'cord_management', 'thermal_Care', 'volume_guarantee', 
                       'caffiene', 'embm_receipt', 'probiotics', 'hydrocortisone')) %>%
  filter(!is.na(gestation) & !is.na(weight) & !is.na(births))
  
# Logic checks

# Check 1: 