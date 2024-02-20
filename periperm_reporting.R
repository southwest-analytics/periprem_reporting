# 0. Load libraries and define functions ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(tidyverse)
library(readxl)

fnCheckWeightGestationBirthLogic <- function(w, g, b){
  exclusion <- (
    (w %in% c('<1500g', '>1500g') & (g %in% c('28 - 29+6', '30 - 31+6', '32 - 33+6'))) | # Singleton|Mutliple
      (w %in% c('<1500g', '>1500g') & (g == c('27 - 27+6')) & (b=='Singleton'))
  )
  return(exclusion)
}

# Logic Test
for(w in c('<800g','<1500g','>1500g'))
  for(g in c('<26+6', '27 - 27+6', '28 - 29+6', '30 - 31+6', '32 - 33+6'))
    for(b in c('Singleton', 'Multiple'))
    {
      print(sprintf('W = %s, G = %s, B = %s, Logic = %s', w, g, b, ifelse(fnCheckWeightGestationBirthLogic(w, g, b), 'Excluded', 'Included')))
    }

# 1. Read input worksheet ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Read in entire sheet
df <- read_excel(path = './input/Example_Data.xlsx', 
                 sheet = 'Tab 2 Data ONLY EDIT THIS TAB',
                 col_names = FALSE) %>% 
  # Add Excel row number
  mutate(excel_row = as.integer(row.names(.)), .before = 1)

# Extract trust name (Cell H3)
trust_name <- df[3, (8+1)]

# Extract perinatal leads (Cell P3)
perinatal_leads <- df[3, (16+1)]

# Extract data entry cells
df <- df[10:NROW(df),1:(24+1)] %>% 
  rename_with(.fn = ~c('excel_row', 'gestation', 'weight', 'births', 'ventilation', 'active_labour', 
                       'place', 'antenatal_steroid_receipt', 'antenatal_steroid_doses', 'antenatal_steroid_optimal_pos', 'antenatal_steroid_optimal_act', 
                       'antenatal_MgSO4_receipt', 'antenatal_MgSO4_optimal_pos', 'antenatal_MgSO4_optimal_act', 
                       'intrapartum_antibiotics', 'intrapartum_antibiotics_optimal_pos', 'intrapartum_antibiotics_optimal_act', 
                       'embm_information', 'cord_management', 'thermal_Care', 'volume_guarantee', 
                       'caffiene', 'embm_receipt', 'probiotics', 'hydrocortisone')) %>%
  filter(!is.na(gestation) & !is.na(weight) & !is.na(births))
  
# 2. Logic checks ----
# ~~~~~~~~~~~~~~~~~~~~




# Weight, Gestation and Births (wgb_exc) exclusion criteria
df$wgb_exc[df$weight!='<800g' & 
             !(df$gestation %in% c('<26+6', '27 - 27+6')) &
             
)

# Weight - Not < 800g AND
# Gestation - Not '28 - 29+6', '30 - 31+6', '32 - 33+6'
# Births - Singleton or Multiple



Singleton 27 - 27+6, 



# Check 1: 