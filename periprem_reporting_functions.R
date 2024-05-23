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
  # If any of the gestation, birth or weight fields are NA fail the check
  # Otherwise fail the check if the place entry is not Yes|No for high risk births
  # A high risk birth is any <800g birth OR if the gestation is <26+6 OR (if
  # gestation is <27+6 AND the birth is a multiple birth)
  # For all other combinations the place entry should be NA
  return(
    if_else(
      is.na(df$gestation) | 
        is.na(df$weight) |
        is.na(df$births),
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
  # should be NA or 0 otherwise the entry should be 1 or 2
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
  # If receipt is NA then fail
  
  # Otherwise if receipt is NO then we are not concerned with optimising
  # administration so poss should be NA
  
  # If receipt is YES then poss must be YES|NO
  return(
    if_else(
      is.na(df$steroids_rx),
      FALSE,
      if_else(
        df$steroids_rx=='No',
        true = is.na(df$steroids_opt_poss),
        false = df$steroids_opt_poss %in% c('Yes','No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_steroids_opt_act <- function(df){
  # If receipt is NA fail check
  
  # If receipt is NO then opt. poss. and opt. act. should be NA as 
  # optimisation is a redundant question any other use of NA for opt. poss. or 
  # opt. act. is invalid
  
  # If the receipt is YES and opt. poss. is NO the only valid response for 
  # opt. act. is NA
  
  # If the receipt is YES and opt. poss. is YES the only valid responses for 
  # opt. act. are YES and NO
  return(
    if_else(
      # If the receipt field is missing fail the check
      is.na(df$steroids_rx),
      true = FALSE,
      # Otherwise if receipt is No
      false = if_else(
        df$steroids_rx=='No',
        # The only valid entries for poss and act are NA
        true =  is.na(df$steroids_opt_poss) & is.na(df$steroids_opt_act),
        # Otherwise receipt must be Yes and...
        false = if_else(
          # If the poss entry is NA then fail
          is.na(df$steroids_opt_poss),
          true = FALSE,
          # Otherwise if poss is Yes then...
          if_else(
            df$steroids_opt_poss=='Yes',
            # ...the only valid entries for opt. act. are Yes|No
            true = df$steroids_opt_act %in% c('Yes','No'),
            # otherwise if poss must be No and the only valid entry for act is NA
            false = is.na(df$steroids_opt_act),
            missing = NA
          ),
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
  # If gestation is NA then fail
  
  # Otherwise if gestation >= 30 then receipt should be NA
  
  # Otherwise if getation < 30 then receipt should be YES|NO
  return(
    if_else(
      is.na(df$gestation),
      true = FALSE,
      false = if_else(
        df$gestation %in% c('30 - 31+6', '32 - 33+6'),
        true = is.na(df$mgso4_rx),
        false = df$mgso4_rx %in% c('Yes','No'),
        missing = NA
      ),
      missing = NA
    )
  )
}  

fnCheck_mgso4_opt_poss <- function(df){
  # If gestation is NA then fail

  # Otherwise if gestation >= 30 then then receipt should be NA and
  # so poss should also be NA as we are not concerned with optimising administration
  
  # Otherwise if gestation < 30 then then receipt should be YES|NO
  # If receipt is NO we are not concerned with optimising administration and
  # poss should be NA
  
  return(
    if_else(
      is.na(df$gestation),
      true = FALSE,
      # Valid gestation entry
      false = if_else(
        # If gestation >30 then we are not concerned about optimisation 
        # so receipt and poss should be NA
        df$gestation %in% c('30 - 31+6', '32 - 33+6') ,
        true = is.na(df$mgso4_rx) & is.na(df$mgso4_opt_poss),
        # Otherwise gestation < 30 so receipt should not be NA
        false = if_else(
          is.na(df$mgso4_rx),
          true = FALSE,
          false = if_else(
            df$mgso4_rx=='No',
            # If not in receipt then not concerned about optimisation
            true = is.na(df$mgso4_opt_poss),
            # Otherwise we are
            false = !is.na(df$mgso4_opt_poss),
            missing = NA
          ),
          missing = NA
        ),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_mgso4_opt_act <- function(df){
  # If gestation is NA fail the check

  # Otherwise if gestation >=30 we are not concerned about giving
  # MgSO4 so the receipt, poss and act fields should be NA
  
  # If gestation is <30 we need to have Yes|No for the receipt and so NA 
  # for receipt should fail
  
  # If receipt is NO then we are not concerned about optimisation so
  # poss and act should be NA
  
  # If receipt is YES then... 
  # ...if poss is NO then act should be NA
  # ...otherwise if poss is YES then act should be YES|NO
  return(
    if_else(
      is.na(df$gestation),
      true = FALSE,
      false = if_else(
        df$gestation %in% c('30 - 31+6', '32 - 33+6'),
        true = is.na(df$mgso4_rx) & is.na(df$mgso4_opt_poss) & is.na(df$mgso4_opt_act),
        # Otherwise gestation is <30 we are concerned about receipt 
        false = if_else(
          # If receipt is NA then fail
          is.na(df$mgso4_rx),
          true = FALSE,
          # ...otherwise if receipt is NO poss and act should be NA
          false = if_else(
            df$mgso4_rx=='No',
            true = is.na(df$mgso4_opt_poss) & is.na(df$mgso4_opt_act),
            # Otherwise receipt must be YES so...
            false = if_else(
              # If the poss entry is NA then fail
              is.na(df$mgso4_opt_poss),
              true = FALSE,
              # Otherwise if poss is NO
              false = if_else(
                df$mgso4_opt_poss=='No',
                # Then act should be NA
                true = is.na(df$mgso4_opt_act),
                # Otherwise if poss is YES act should be YES|NO
                false = df$mgso4_opt_act %in% c('Yes','No'),
                missing = NA
              ),
              missing = NA
            ),
            missing = NA
          ),
          missing = NA
        ),
        missing = NA
      ),
      missing = NA
    )
  )
}

# 1.5. - Antibiotics ----
# ───────────────────────
fnCheck_antibiotics_rx <- function(df){
  # If labour is NA then fail
  
  # Otherwise if labour is NO then receipt should be NA
  
  # Otherwise labour is YES and receipt should be YES|NO
  return(
    if_else(
      is.na(df$labour),
      true = FALSE,
      false = if_else(
        df$labour=='No',
        true = is.na(df$antibiotics_rx),
        false = df$antibiotics_rx %in% c('Yes','No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_antibiotics_opt_poss <- function(df){
  # If labour is NA then fail
  
  # Otherwise if labour is NO then both receipt and poss should be NA
  
  # Otherwise labour is YES and receipt should be YES|NO...
  
  # If receipt is NO then poss should be NA
  # Otherwise receipt is YES and poss should be YES|NO
  
  return(
    if_else(
      # If labour is NA then fail
      is.na(df$labour),
      true = FALSE,
      # Otherwise...
      false = if_else(
        # If labour is NO...
        df$labour=='No',
        # Then both receipt and poss should be NA
        true = is.na(df$antibiotics_rx) & is.na(df$antibiotics_opt_poss),
        # Otherwise labour is YES and receipt should be YES|NO
        false = if_else(
          is.na(df$antibiotics_rx),
          true = FALSE,
          false = if_else(
            # If receipt is NO then poss should be NA
            df$antibiotics_rx == 'No',
            true = is.na(df$antibiotics_opt_poss),
            # Otherwise it should be YES|NO
            false = df$antibiotics_opt_poss %in% c('Yes','No'),
            missing = NA
          ),
          missing = NA
        ),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_antibiotics_opt_act <- function(df){
  # If labour is NA then fail
  
  # Otherwise if labour is NO then receipt, poss and act should be NA
  
  # Otherwise labour is YES and receipt should be YES|NO...
  
  # If receipt is NO then poss and act should be NA
  # Otherwise receipt is YES and poss should be YES|NO
  
  # If poss is NO then act should be NA
  
  # If poss is YES then act should be YS|NO
  
  return(
    if_else(
      # If labour is NA then fail
      is.na(df$labour),
      true = FALSE,
      # Otherwise...
      false = if_else(
        # If labour is NO...
        df$labour=='No',
        # Then receipt, poss and act should be NA
        true = is.na(df$antibiotics_rx) & is.na(df$antibiotics_opt_poss) & is.na(df$antibiotics_opt_act),
        # Otherwise labour is YES and receipt should be YES|NO
        false = if_else(
          is.na(df$antibiotics_rx),
          true = FALSE,
          false = if_else(
            # If receipt is NO then poss and act should be NA
            df$antibiotics_rx == 'No',
            true = is.na(df$antibiotics_opt_poss) & is.na(df$antibiotics_opt_act),
            # Otherwise receipt must be YES so...
            false = if_else(
              # If the poss entry is NA then fail
              is.na(df$antibiotics_opt_poss),
              true = FALSE,
              # Otherwise if poss is NO
              false = if_else(
                df$antibiotics_opt_poss=='No',
                # Then act should be NA
                true = is.na(df$antibiotics_opt_act),
                # Otherwise poss is YES and act should be YES|NO
                false = df$antibiotics_opt_act %in% c('Yes','No'),
                missing = NA,
              ),
              missing = NA
            ),
            missing = NA
          ),
          missing = NA
        ),
        missing = NA
      ),
      missing = NA
    )
  )
}

# 1.6. - Rest of bundle ----
# ──────────────────────────

# NB: Early Maternal Breast Milk information is not currently validated
# fnCheck_embm_info <- function(df){
#   # Fail check if early maternal breast milk information is NA
#   return(!is.na(df$embm_info))
#   thermal_care
# }

fnCheck_cord_mgt <- function(df){
  # Fail check if cord management is NA
  return(!is.na(df$cord_mgt))
}

fnCheck_thermal_care <- function(df){
  # Fail check if thermal care is NA
  return(!is.na(df$thermal_care))
}

fnCheck_volume_guarantee <- function(df){
  # If the ventilation field is NA then fail
  
  # If the ventilation field is No then volume guarantee should be NA
  # otherwise volume guarantee should be YES|NO
  return(
    if_else(
      is.na(df$ventilation),
      true = FALSE,
      false = if_else(
        df$ventilation=='No',
        true = is.na(df$volume_guarantee),
        false = df$volume_guarantee %in% c('Yes','No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_caffeine <- function(df){
  # If the gestation field is NA then fail
  
  # If gestation >=30 wks then caffeine should be NA
  # otherwise it should be YES|NO
  return(
    if_else(
      is.na(df$gestation),
      true = FALSE,
      false = if_else(
        df$gestation %in% c('30 - 31+6', '32 - 33+6'),
        true = is.na(df$caffeine),
        false = df$caffeine %in% c('Yes', 'No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_embm_rx <- function(df){
  # Fail check if early maternal breast milk given is NA
  return(!is.na(df$embm_rx))
}

fnCheck_probiotics <- function(df){
  # If the gestation or weight fields are NA then fail
  
  # If gestation >=32 wks then probiotics should be NA or
  # if the birth weight is >1500g then probiotics should be NA
  
  # otherwise it should be YES|NO
  return(
    if_else(
      is.na(df$gestation) | is.na(df$weight),
      true = FALSE,
      false = if_else(
        df$gestation=='32 - 33+6' & df$weight=='>1500g',
        true = is.na(df$probiotics),
        false = df$probiotics %in% c('Yes', 'No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

fnCheck_hydrocortisone <- function(df){
  # If the gestation field is NA then fail
  
  # If gestation >=28 wks then hydrocortisone should be NA or

  # otherwise it should be YES|NO
  return(
    if_else(
      is.na(df$gestation),
      true = FALSE,
      false = if_else(
        df$gestation %in% c('28 - 29+6', '30 - 31+6', '32 - 33+6'),
        true = is.na(df$hydrocortisone),
        false = df$hydrocortisone %in% c('Yes', 'No'),
        missing = NA
      ),
      missing = NA
    )
  )
}

