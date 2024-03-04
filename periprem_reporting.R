# 0. Load libraries and define functions ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(tidyverse)
library(readxl)

# 1.1. - Main Sections ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~
fnCheck_gestation <- function(df){
  # No check required for gestation as the data frame loading 
  # will filter out any row than has NA in the gestation field but
  # for completeness we will fail the cehck if gestation is NA
  return(!is.na(df$gestation))
}

fnCheck_weight <- function(df){
  # Fail check if weight is NA
  return(!is.na(df$weight))
}

fnCheck_births <- function(df){
  # Fail check if birth is not Sinlge|Multiple
  return(df$births %in% c('Single', 'Multiple'))
}

fnCheck_ventilation <- function(df){
  # Fail check if ventilation is not Yes|No
  return(df$ventilation %in% c('Yes', 'No'))
}

fnCheck_labour <- function(df){
  # Fail check to is labour is not Yes|No
  return(df$labour %in% c('Yes', 'No'))
}

# 1.2. - Place ----
# ~~~~~~~~~~~~~~~~~
fnCheck_place <- function(df){
  # Fail check if gestation, birth or weight are NA
  # Otherwise fail check if the entry is not Yes|No for the
  # high risk births 
  # i.e. if birth weight is <800g for any birth, OR
  # if the gestation is <26+6 for any birth, OR 
  # if the gestation is <27 - 27+6 and it is a multiple birth 
  # for all other possibilities the entry should be NA
  return(
    if_else(
      is.na(df$gestation) | 
        is.na(df$weight) |
        is.na(df$birth),
      FALSE,
      if_else(
        df$weight=='<800g' |
        df$gestation=='<26+6' |
        (df$births == 'Multiple' & df$gestation=='27 - 27+6'), 
        df$place %in% c('Yes','No'), 
        false = is.na(df$place),
        missing = NA
      ),
      missing = NA
    )
  )
}

# 1.3. - Steroids ----
# ~~~~~~~~~~~~~~~~~~~~
fnCheck_steroids_rx <- function(df){
  # Simple check to ensure a entry is present
  return(!is.na(df$steroids_rx))
}

fnCheck_steroids_doses <- function(df){
  # If the steriods_rx field is NA then fail the check, 
  # otherwise if the mother is not in receipt of steroids then the entry 
  # should be NA (or presumably 0) otherwise the entry should be 1 or 2
  return(
    if_else(
      is.na(df$steroids_rx),
      FALSE,
      if_else(
        df$steroids_rx=='No',
        true = (is.na(df$steroids_doses) | df$steroids_doses=='0'),
        false = df$steroids_doses %in% c('1','2'),
        missing = NA),
      missing = NA
    )
  )
}

fnCheck_steroids_opt_poss <- function(df){
  # If the steriods_rx field is NA then fail the check, 
  # otherwise if mother is not in receipt of steroids then the entry 
  # should be NA otherwise the entry should be Yes|No
  return(
    if_else(
      is.na(df$steroids_rx),
      FALSE,
      if_else(
        df$steroids_rx=='No',
        is.na(df$steroids_opt_poss),
        df$steroids_opt_poss %in% c('Yes','No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_steroids_opt_act <- function(df){
  # If the mother is not in receipt of steroids or it was not possible to
  # optimally administer the steroids then the entry should be NA 
  # otherwise the entry should be Yes|No
  return(
    # If either the receipt or opt. poss. fields are NA flag the check as failed
    if_else(
      is.na(df$steroids_rx) | is.na(df$steroids_opt_poss),
      FALSE,
      # Otherwise if the receipt or the opt. poss. fields are
      # No then flag the check as failed is the opt. act. field is 
      # anything but NA
      if_else(
        df$steroids_rx=='No' | df$steroids_opt_poss == 'No',
        true = is.na(df$steroids_opt_act),
        false = df$steroids_opt_act %in% c('Yes','No'),
        missing = NA
      )
    )
  )
}

# 1.4 - Magnesium Sulphate ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fnCheck_mgso4_rx <- function(df){
  # If the gestation period is greater than or equal to 30 wks then the
  # entry should be NA, otherwise the entry should be Yes|No
  return(
    if_else(
      df$gestation %in% c('30 - 31+6', '32 - 33+6'),
      true = is.na(df$mgso4_rx),
      false = df$mgso4_rx %in% c('Yes','No'),
      missing = NA
    )
  )
}  

fnCheck_mgso4_opt_poss <- function(df){
  # If the gestation period is greater than or equal to 30 wks and 
  # the mother did not receive MgSO4 then the entry should be NA, 
  # otherwise the entry should be Yes|No
  return(
    if_else(
      df$gestation %in% c('30 - 31+6', '32 - 33+6') & df$mgso4_rx == 'No',
      true = is.na(df$mgso4_opt_poss),
      false = df$mgso4_opt_poss %in% c('Yes','No'),
      missing = NA
    )
  )
}

fnCheck_mgso4_opt_act <- function(df){
  return(
    if_else(
      df$gestation %in% c('30 - 31+6', '32 - 33+6') & 
        df$mgso4_rx == 'No' &
        df$mgso4_opt_poss == 'No',
      true = is.na(df$mgso4_opt_act),
      false = df$mgso4_opt_act %in% c('Yes','No'),
      missing = NA
    )
  )
}

# 1.5. - Antibiotics ----
# ~~~~~~~~~~~~~~~~~~~~~~~
fnCheck_antibiotics_rx <- function(df){
  return()
}
fnCheck_antibiotics_opt_poss <- function(df){
  return()
}
fnCheck_antibiotics_opt_act <- function(df){
  return()
}

# 1.6. - Rest of bundle
# ~~~~~~~~~~~~~~~~~~~~~~~
fnCheck_embm_info <- function(df){
  return()
}
fnCheck_cord_mgt <- function(df){
  return()
}
fnCheck_thermal_care <- function(df){
  return()
}
fnCheck_volume_guarantee <- function(df){
  return()
}
fnCheck_caffiene <- function(df){
  return()
}
fnCheck_embm_rx <- function(df){
  return()
}
fnCheck_probiotics <- function(df){
  return()
}
fnCheck_hydrocortisone <- function(df){
  return()
}









fnPlaceOfBirthCheck <- function(df){
  # If birth weight is <800g for any birth, OR
  # ... if the gestation is <26+6, OR 
  # ... if the gestation is <27 - 27+6 and it is a multiple birth
  # then the place field should contain a Yes|No and not an NA
  return(
    if_else(
      df$weight=='<800g' |
        df$gestation=='<26+6' |
        (df$births == 'Multiple' & df$gestation=='<27 - 27+6'), 
      true = df$place %in% c('Yes','No'), 
      false = is.na(df$place),
      missing = NA
    )
  )
}

# excel_row, 
# gestation, weight, births, ventilation, labour, 
# place, 
# steroids_rx, steroids_doses, steroids_opt_poss, steroids_opt_act, 
# mgso4_rx, mgso4_opt_poss, mgso4_opt_act, 
# antibiotics_rx, antibiotics_opt_poss, antibiotics_opt_act, 
# embm_info, cord_mgt, thermal_care, volume_guarantee, 
# caffiene, embm_rx, probiotics, hydrocortisone
  
fnSteroidDosesCheck <- function(df){
  # If the mother was in receipt of antenatal steroids then
  # the doses entry should be 0 to 2 otherwise it should be NA
  return(if_else(steroids_rx=='No',
                 true = is.na(steroids_doses),
                 false = steroids_doses %in% c('0', '1', '2'),
                 missing = NA
                 )
  )
}

fnSteroidDosesCheck <- function(df){
  # If the mother was in receipt of antenatal steroids then
  # the optimal administration possible entry should be Yes|No otherwise 
  # it should be NA
  return(if_else(steroids_rx=='No',
                 true = is.na(steroids_opt_poss),
                 false = steroids_opt_poss %in% c('0', '1', '2'),
                 missing = NA
  )
  )
}

        gestation=='<26+6' |
        (births == 'Multiple' & gestation=='<27 - 27+6'), 
      place %in% c('Yes','No'), is.na(place))
    )
  return(df)
  
  
  # If mother has not received antenatal steroids, then 
  # number of steroid doses and actual optimisation should both
  # be NA. If the mother has received antenatal steroids and the
  # optimisation was not possible then actual optimisation should
  # be NA.
  
  return(df)
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
  rename_with(.fn = ~c('excel_row', 
                       'gestation', 'weight', 'births', 'ventilation', 'labour', 
                       'place', 
                       'steroids_rx', 'steroids_doses', 'steroids_opt_poss', 'steroids_opt_act', 
                       'mgso4_rx', 'mgso4_opt_poss', 'mgso4_opt_act', 
                       'antibiotics_rx', 'antibiotics_opt_poss', 'antibiotics_opt_act', 
                       'embm_info', 'cord_mgt', 'thermal_care', 'volume_guarantee', 
                       'caffiene', 'embm_rx', 'probiotics', 'hydrocortisone')) %>%
  filter(!is.na(gestation) & !is.na(weight) & !is.na(births))
  
# 2. Logic checks ----
# ~~~~~~~~~~~~~~~~~~~~

# Place of birth
df <- fnPlaceOfBirthCheck(df)

# Antenatal steroids
df <- fnAntenatalSteroidCheck(df)



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



df$

fnTestRow <- function(df){
  if(df$weight=='<800g' | (df$gestation=='<26+6') | (df$births=='Multiple' & g=='<27 - 27+6'){
    if(!(df$place %in% c('Yes','No'))){
      fnReportError(logfile,
                    data = df, 
                    section = 'Place of Birth', 
                    msg = 'High risk birth requires Yes|No entry for "Place of Birth - Was this baby born in an appropriate unit for gestation and birth weight?"')
    }
  } else
}


library(leaflet)
library(sf)

sf <- st_read(dsn='D:/Data/OpenGeography/Shapefiles/ICB22',
              layer = 'ICB22') %>%
  st_transform(crs = 4326)

leaflet() %>%
  addTiles() %>%
  addPolygons(data = sf)



fnTemp <- function(df){
  return(
    if_else(
      df$weight=='<800g' |
        df$gestation=='<26+6' |
        (df$births == 'Multiple' & df$gestation=='<27 - 27+6'), 
      true = df$place %in% c('Yes','No'), 
      false = is.na(df$place),
      missing = NA
    )
  )
}

dfTmp <- df %>% mutate(my_check = fnTemp(df = .))


dfTmp <- data.frame(
  expand.grid(
    gestation =  c(NA, '<26+6', '27 - 27+6', '28 - 29+6', '30 - 31+6', '32 - 33+6'),
    mgso4_rx = c(NA, 'Yes', 'No'),
    mgso4_opt_poss = c(NA, 'Yes', 'No'),
    mgso4_opt_act = c(NA, 'Yes', 'No')
  )
)

write.csv(dfTmp %>% mutate(
  check_mgso4_rx = fnCheck_mgso4_rx(.),
  check_mgso4_opt_poss = fnCheck_mgso4_opt_poss(.),
  check_mgso4_opt_act = fnCheck_mgso4_opt_act(.)
  ),
  'temp.csv')

fnCheck_steroids_opt_act <- function(df){
  # If the mother is not in receipt of steroids or it was not possible to
  # optimally administer the steroids then the entry should be NA 
  # otherwise the entry should be Yes|No
  return(
    if_else(
      df$steroids_rx=='No' | df$steroids_opt_poss == 'No',
      true = is.na(df$steroids_opt_act),
      false = df$steroids_opt_act %in% c('Yes','No'),
      missing = NA
    )
  )
}


#######################################################################

# Truth Table - Main Sections ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

data.frame(gestation = c(NA, '<26+6', '27 - 27+6', '28 - 29+6', '30 - 31+6', '32 - 33+6')) %>% 
  mutate(check = fnCheck_gestation(.))

data.frame(weight = c(NA, '<800g', '<1500g', '>1500g')) %>%
  mutate(check = fnCheck_weight(.))
  
data.frame(births = c(NA, 'Single', 'Multiple')) %>%
  mutate(check = fnCheck_births(.))

data.frame(ventilation = c(NA, 'Yes', 'No')) %>%
  mutate(check = fnCheck_ventilation(.))

data.frame(labour = c(NA, 'Yes', 'No')) %>% 
    mutate(check = fnCheck_labour(.))

# Truth Table - Place ----
# ~~~~~~~~~~~~~~~~~~~~~~~~

data.frame(
  expand.grid(
    gestation = c(NA, '<26+6', '27 - 27+6', '28 - 29+6', '30 - 31+6', '32 - 33+6'),
    weight = c(NA, '<800g', '<1500g', '>1500g'),
    births = c(NA, 'Single', 'Multiple'),
    place = c(NA, 'Yes', 'No')
  )) %>% 
  mutate(check = fnCheck_place(.)) %>% 
  filter(!check & 
          !is.na(gestation) &
          !is.na(weight) &
          !is.na(births))


# Truth Table - Steroids ----
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~
data.frame(steroids_rx = c(NA, 'Yes', 'No')) %>% 
  mutate(check = fnCheck_steroids_rx(.))



data.frame(
  expand.grid(
    steroids_rx = c(NA, 'Yes', 'No'),
    steroids_doses = c(NA, '0', '1', '2')
  )) %>%
  mutate(check = fnCheck_steroids_doses(.)) %>% 
  filter(!check)

data.frame(
  expand.grid(
    steroids_rx = c(NA, 'Yes', 'No'),
    steroids_opt_poss = c(NA, 'Yes', 'No')
  )) %>%
  mutate(check = fnCheck_steroids_opt_poss(.)) %>%
  arrange(steroids_rx, steroids_opt_poss) %>%
  write.csv('truth_table.csv')

data.frame(
  expand.grid(
    steroids_rx = c(NA, 'Yes', 'No'),
    steroids_opt_poss = c(NA, 'Yes', 'No'),
    steroids_opt_act = c(NA, 'Yes', 'No')
  )) %>%
  mutate(check = fnCheck_steroids_opt_act(.)) %>%
  filter(check)




fnCheck_steroids_opt_act
df$steroids_rx
df$steroids_opt_poss
is.na(df$steroids_opt_act


# Field options
gestation = c('<26+6', '27 - 27+6', '28 - 29+6', '30 - 31+6', '32 - 33+6', NA)
weight = c('<800g', '<1500g', '>1500g', NA)
births = c('Single', 'Multiple', NA)
ventilation = c('No', 'Yes', NA)
labour = c('No', 'Yes', NA)
place = c('No', 'Yes', NA)
steroids_rx = c('No', 'Yes', NA)
steroids_doses = c('0', '1', '2', NA)
steroids_opt_poss = c('No', 'Yes', NA)
steroids_opt_act = c('No', 'Yes', NA)
mgso4_rx = c('No', 'Yes', NA)
mgso4_opt_poss = c('No', 'Yes', NA)
mgso4_opt_act = c('No', 'Yes', NA)
antibiotics_rx = c('No', 'Yes', NA)
antibiotics_opt_poss = c('No', 'Yes', NA)
antibiotics_opt_act = c('No', 'Yes', NA)
embm_info = c('No', 'Yes', NA)
cord_mgt = c('No', 'Yes', NA)
thermal_care = c('No', 'Yes', NA)
volume_guarantee = c('No', 'Yes', NA)
caffiene = c('No', 'Yes', NA)
embm_rx = c('No', 'Yes', NA)
probiotics = c('No', 'Yes', NA)
hydrocortisone = c('No', 'Yes', NA)


data.frame(gestation = lst_options[] fnCheck_gestation
