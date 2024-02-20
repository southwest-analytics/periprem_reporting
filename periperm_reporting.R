# 0. Load libraries and define functions ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(tidyverse)
library(readxl)

fnPlaceOfBirthLogic <- function(w, g, b){
  exclusion <- (
    # If birth weight is <800g for any birth, OR 
    # if the gestation is <26+6 for a singleton, OR 
    # if the gestation is less than <27 - 27+6 (ie is <26+6 OR <27 - 27+6) for multiple birth
    # the question over correct place of birth should be asked as optimal place 
    # of birth should have been a NICU tertiary centre, otherwise it can be ignored as 
    # the optimal place of birth could have been any centre.
    if(w=='<800g'){
      TRUE
    } else if(g=='<26+6'){
      TRUE
    } else if(b=='Multiple' & g=='<27 - 27+6'){
      TRUE
    }
  )
  return(exclusion)
}

# # Logic Debug Test
# for(w in c('<800g','<1500g','>1500g'))
#   for(g in c('<26+6', '27 - 27+6', '28 - 29+6', '30 - 31+6', '32 - 33+6'))
#     for(b in c('Single', 'Multiple'))
#     {
#       print(sprintf('W = %s, G = %s, B = %s, Logic = %s', w, g, b, ifelse(fnCheckWeightGestationBirthLogic(w, g, b), 'Excluded', 'Included')))
#     }

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

# Place of birth
df <- df %>% 
  mutate(place_exclusion = fnCheckWeightGestationBirthLogic(weight, gestation, births))

place_of_birth_errors <- df$excel_row[(!is.na(df$place) & df$place_exclusion)]

# Antenatal steroids
# ~~~~~~~~~~~~~~~~~~
# If mother did not receive steroids then nothing should have been entered for doses
antenatal_steroid_doses_errors <- df$excel_row[!is.na(df$antenatal_steroid_doses) & 
                                                 df$antenatal_steroid_receipt=='No']
# If mother did not receive steroids then nothing should have been entered for optimal administration possible
antenatal_steroid_optimal_pos_errors <- df$excel_row[!is.na(df$antenatal_steroid_optimal_pos) & 
                                                       df$antenatal_steroid_receipt=='No']
# If mother did not receive steroids or optimal administration not possible then nothing 
# should have been entered for optimal administration delivered
antenatal_steroid_optimal_act_errors <- df$excel_row[!is.na(df$antenatal_steroid_optimal_act) & 
                                                       (df$antenatal_steroid_receipt=='No' |
                                                          df$antenatal_steroid_optimal_pos=='No')]
# Antenatal MgSO4
# ~~~~~~~~~~~~~~~
# If gestation is greater than 30 weeks nothing should have been entered for MgSO4 receipt
antenatal_MgSO4_receipt_error <- df$excel_row[!is.na(df$antenatal_MgSO4_receipt) & 
                                                (df$gestation %in% c('30 - 31+6', '32 - 33+6'))]
# If gestation is greater than 30 weeks or mother not in receipt of MgSO4 then nothing
# should have been entered for optimal administration possible
antenatal_MgSO4_receipt_error <- df$excel_row[!is.na(antenatal_MgSO4_optimal_pos) & 
                                                (df$gestation %in% c('30 - 31+6', '32 - 33+6') |
                                                   df$antenatal_MgSO4_receipt=='No')]

# If gestation is greater than 30 weeks or mother not in receipt of MgSO4 or 
# optimal administration not possible then nothing should have been entered for 
# optimal administration delivered
antenatal_MgSO4_receipt_error <- df$excel_row[!is.na(antenatal_MgSO4_optimal_pos) & 
                                                (df$gestation %in% c('30 - 31+6', '32 - 33+6') |
                                                   df$antenatal_MgSO4_receipt=='No' |
                                                   df$antenatal_MgSO4_optimal_pos=='No')]

# Intrapartum Antibiotics
# ~~~~~~~~~~~~~~~~~~~~~~~
# If mother was not in active labour prior to delivery then nothing should have been
# added 


# Check 1: 