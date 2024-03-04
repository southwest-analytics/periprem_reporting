# 1. Load libraries and define functions ----
# ───────────────────────────────────────────

library(tidyverse)
library(readxl)

# 1.1. - Main Sections ----
# ─────────────────────────
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
# ─────────────────
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
# ────────────────────
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
  # *********
  # IMPORTANT 
  # *********

  # Terrible structure here, really needs to be simplified also doesn't check 
  # for the correct number of doses given, surely that should be one of the checks
  # or if not then the doses should be removed as an entry as it is not used elsewhere
  
  # If the mother is not in receipt of steroids then both the opt. poss. and
  # opt. act. entries should be NA, if the mother was in receipt of steroids 
  # and the opt. poss. entry was Yes the opt. act. entry should be Yes|No, 
  # otherwise if the opt. poss. entry was No the opt. act. entry should be NA, 
  # all other combinations will fail the check
  return(
    if_else(
      # If the receipt field is missing fail the check
      is.na(df$steroids_rx),
      true = FALSE,
      # Otherwise if receipt is No and opt. poss. and opt. act. fields are NA then pass the check
      false = if_else(
        df$steroids_rx=='No' & is.na(df$steroids_opt_poss) & is.na(df$steroids_opt_act),
        true = TRUE,
        false = if_else(
          # Otherwise if receipt Yes...
          df$steroids_rx=='Yes',
          true = if_else(
            # ... and the opt. poss. field is missing then fail the check ...
            is.na(df$steroids_opt_poss),
            true = FALSE,
            # ... otherwise if the opt. poss. field is Yes then 
            false = if_else(
              df$steroids_opt_poss=='Yes',
              true = !is.na(df$steroids_opt_act),
              false = is.na(df$steroids_opt_act),
              missing = NA
            ),
            missing = NA
          ),
          false = FALSE,
          missing = NA
        ),
        missing = NA
      ),
      missing = NA
    )
  )
}

# 1.4 - Magnesium Sulphate ----
# ─────────────────────────────
fnCheck_mgso4_rx <- function(df){
  # If the gestation period is greater than or equal to 30 wks then the
  # entry should be NA, otherwise the entry should be Yes|No
  return(
    if_else(
      df$gestation %in% c('30 - 31+6', '32 - 33+6'),
      true = is.na(df$mgso4_rx),
      false = df$mgso4_rx %in% c('Yes','No') & !is.na(df$gestation),
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
      is.na(df$gestation),
      true = FALSE,
      false = if_else(
        df$gestation %in% c('30 - 31+6', '32 - 33+6'),
        true = is.na(df$mgso4_rx) & is.na(df$mgso4_opt_poss),
        false = if_else(
          !is.na(df$mgso4_rx),
          true = if_else(
            df$mgso4_rx=='No',
            true = is.na(df$mgso4_opt_poss),
            false = !is.na(df$mgso4_opt_poss),
            missing = NA
          ),
          false = FALSE,
          missing = NA
        ),
        missing = NA
      ),
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
# ───────────────────────
fnCheck_antibiotics_rx <- function(df){
  return()
}

fnCheck_antibiotics_opt_poss <- function(df){
  return()
}
fnCheck_antibiotics_opt_act <- function(df){
  return()
}

# 1.6. - Rest of bundle ----
# ──────────────────────────
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


# data.frame(
#   expand.grid(active_labour = c(NA, 'No', 'Yes'),
#               antibiotics_rx = c(NA, 'No', 'Yes'),
#               antibiotics_opt_poss = c(NA, 'No', 'Yes'),
#               antibiotics_opt_act = c(NA, 'No', 'Yes'))
#   ) %>%
#   arrange(active_labour, antibiotics_rx, antibiotics_opt_poss, antibiotics_opt_act)