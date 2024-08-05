library(tidyverse)
library(lubridate)

df_org_lu <- data.frame(org_code = c('GLO', 'GWH', 'MUS', 'NBT', 'RCHT', 
                                     'RDUE', 'RDUN', 'RUH', 'TOR', 'UHBW', 
                                     'UHP', 'YEO'),
                        icb_code = c('GLO', 'BSW', 'SOM', 'BNSSG', 'CIOS', 
                                     'DEV', 'DEV', 'BSW', 'DEV', 'BNSSG', 
                                     'DEV', 'SOM'),
                        hin_code = c('HIWoE', 'HIWoE', 'HISW', 'HIWoE', 'HISW', 
                                     'HISW', 'HISW', 'HIWoE', 'HISW', 'HIWoE', 
                                     'HISW', 'HISW'))

df_matneo_sip <- df_historic %>% 
  filter(org_code != 'BSW') %>%
  left_join(df_org_lu, by = 'org_code') %>% 
  mutate(
    org_code,
    icb_code,
    hin_code,
    month,
    financial_quarter = lubridate::quarter(month, fiscal_start = 4, type = 'year.quarter'),
    # Place
    place_elig = place_dem,
    place_rx = place_num,
    place_dnrx = place_dem - place_num,
#    place_rx_pct = place_rx/(place_rx + place_dnrx),
    # Antenatal Steroids
    steroids_elig = steroids_rx_dem,
    steroids_rx = steroids_rx_num,
    steroids_dnrx = steroids_rx_dem - steroids_rx_num,
#    steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx),
    # Antenatal Steroids Optimal
    steroids_opt_elig = steroids_opt_poss_dem,
    steroids_opt_rx = steroids_opt_act_num,
    steroids_opt_dnrx = steroids_rx_dem - steroids_opt_act_num,
#    steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx),
    # MgSO4
    mgso4_elig = mgso4_rx_dem,
    mgso4_rx = mgso4_rx_num,
    mgso4_dnrx = mgso4_rx_dem - mgso4_rx_num,
#    mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx),
    # MgSO4 Optimal
    mgso4_opt_elig = mgso4_opt_poss_dem,
    mgso4_opt_rx = mgso4_opt_act_num,
    mgso4_opt_dnrx = mgso4_rx_dem - mgso4_opt_act_num,
#    mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx),
    # Antibiotics
    antibiotics_elig = antibiotics_rx_dem,
    antibiotics_rx = antibiotics_rx_num,
    antibiotics_dnrx = antibiotics_rx_dem - antibiotics_rx_dem,
#    antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx),
    # Antibiotics Optimal
    antibiotics_opt_elig = antibiotics_opt_poss_dem,
    antibiotics_opt_rx = antibiotics_opt_act_num,
    antibiotics_opt_dnrx = antibiotics_rx_dem - antibiotics_opt_act_num,
#    antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx),
    # Cord Management
    cord_mgt_elig = cord_mgt_dem,
    cord_mgt_rx = cord_mgt_num,
    cord_mgt_dnrx = cord_mgt_dem - cord_mgt_num,
#    cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx),
    # Thermal Care
    thermal_care_elig = thermal_care_dem,
    thermal_care_rx = thermal_care_num,
    thermal_care_dnrx = thermal_care_dem - thermal_care_num,
#    thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx),
    # Ventilation
    ventilation_elig = volume_guarantee_dem,
    ventilation_rx = volume_guarantee_num,
    ventilation_dnrx = volume_guarantee_dem - volume_guarantee_num,
#    ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx),
    # Caffeine
    caffeine_elig = caffeine_dem,
    caffeine_rx = caffeine_num,
    caffeine_dnrx = caffeine_dem - caffeine_num,
#    caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx),
    # Early Maternal Breast Milk
    embm_elig = embm_rx_dem,
    embm_rx = embm_rx_num,
    embm_dnrx = embm_rx_dem - embm_rx_num,
#    embm_rx_pct = embm_rx/(embm_rx + embm_dnrx),
    # Probiotics
    probiotics_elig = probiotics_dem,
    probiotics_rx = probiotics_num,
    probiotics_dnrx = probiotics_dem - probiotics_num,
#    probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx),
    # Hydrocortisone
    hydrocortisone_elig = hydrocortisone_dem,
    hydrocortisone_rx = hydrocortisone_num,
    hydrocortisone_dnrx = hydrocortisone_dem - hydrocortisone_num,
#    hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx),
    .keep = 'none'
  )

dir.create('./output/matneo')

# Monthly by Trust
df_matneo_sip %>% 
  mutate(place_rx_pct = place_rx/(place_rx + place_dnrx), .after = place_dnrx) %>%
  mutate(steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx), .after = steroids_dnrx) %>%
  mutate(steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx), .after = steroids_opt_dnrx) %>%
  mutate(mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx), .after = mgso4_dnrx) %>%
  mutate(mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx), .after = mgso4_opt_dnrx) %>%
  mutate(antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx), .after = antibiotics_dnrx) %>%
  mutate(antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx), .after = antibiotics_opt_dnrx) %>%
  mutate(cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx), .after = cord_mgt_dnrx) %>%
  mutate(thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx), .after = thermal_care_dnrx) %>%
  mutate(ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx), .after = ventilation_dnrx) %>%
  mutate(caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx), .after = caffeine_dnrx) %>%
  mutate(embm_rx_pct = embm_rx/(embm_rx + embm_dnrx), .after = embm_dnrx) %>%
  mutate(probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx), .after = probiotics_dnrx) %>%
  mutate(hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx), .after = hydrocortisone_dnrx) %>%
  dplyr::select(-c('icb_code', 'hin_code', 'financial_quarter')) %>%
  rename_with(.fn = ~c('Trust', 'Month', 
                       'Place - Eligible', 'Place - Received', 'Place - Did Not Receive', 'Place - % Received',
                       'Steroids - Eligible', 'Steroids - Received', 'Steroids - Did Not Receive', 'Steroids - % Received',
                       'Optimal Steroids - Eligible', 'Optimal Steroids - Received', 'Optimal Steroids - Did Not Receive', 'Optimal Steroids - % Received',
                       'MgSO4 - Eligible', 'MgSO4 - Received', 'MgSO4 - Did Not Receive', 'MgSO4 - % Received',
                       'Optimal MgSO4 - Eligible', 'Optimal MgSO4 - Received', 'Optimal MgSO4 - Did Not Receive', 'Optimal MgSO4 - % Received',
                       'Antibiotics - Eligible', 'Antibiotics - Received', 'Antibiotics - Did Not Receive', 'Antibiotics - % Received',
                       'Optimal Antibiotics - Eligible', 'Optimal Antibiotics - Received', 'Optimal Antibiotics - Did Not Receive', 'Optimal Antibiotics - % Received',
                       'Cord Management - Eligible', 'Cord Management - Received', 'Cord Management - Did Not Receive', 'Cord Management - % Received',
                       'Thermal Care - Eligible', 'Thermal Care - Received', 'Thermal Care - Did Not Receive', 'Thermal Care - % Received',
                       'Ventilation - Eligible', 'Ventilation - Received', 'Ventilation - Did Not Receive', 'Ventilation - % Received',
                       'Caffeine - Eligible', 'Caffeine - Received', 'Caffeine - Did Not Receive', 'Caffeine - % Received',
                       'EMBM - Eligible', 'EMBM - Received', 'EMBM - Did Not Receive', 'EMBM - % Received',
                       'Probiotics - Eligible', 'Probiotics - Received', 'Probiotics - Did Not Receive', 'Probiotics - % Received',
                       'Hydrocortisone - Eligible', 'Hydrocortisone - Received', 'Hydrocortisone - Did Not Receive', 'Hydrocortisone - % Received')) %>%
  write.csv('./output/matneo/matneo_sip_monthly_by_trust.csv', row.names = FALSE)

# Monthly by ICB
df_matneo_sip %>% 
  group_by(icb_code, month) %>% 
  summarise(across(.cols = 4:45, .fns = \(x)sum(x , na.rm = TRUE)), .groups = 'keep') %>%
  ungroup() %>% 
  mutate(place_rx_pct = place_rx/(place_rx + place_dnrx), .after = place_dnrx) %>%
  mutate(steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx), .after = steroids_dnrx) %>%
  mutate(steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx), .after = steroids_opt_dnrx) %>%
  mutate(mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx), .after = mgso4_dnrx) %>%
  mutate(mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx), .after = mgso4_opt_dnrx) %>%
  mutate(antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx), .after = antibiotics_dnrx) %>%
  mutate(antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx), .after = antibiotics_opt_dnrx) %>%
  mutate(cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx), .after = cord_mgt_dnrx) %>%
  mutate(thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx), .after = thermal_care_dnrx) %>%
  mutate(ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx), .after = ventilation_dnrx) %>%
  mutate(caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx), .after = caffeine_dnrx) %>%
  mutate(embm_rx_pct = embm_rx/(embm_rx + embm_dnrx), .after = embm_dnrx) %>%
  mutate(probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx), .after = probiotics_dnrx) %>%
  mutate(hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx), .after = hydrocortisone_dnrx) %>%
  rename_with(.fn = ~c('ICB', 'Month', 
                       'Place - Eligible', 'Place - Received', 'Place - Did Not Receive', 'Place - % Received',
                       'Steroids - Eligible', 'Steroids - Received', 'Steroids - Did Not Receive', 'Steroids - % Received',
                       'Optimal Steroids - Eligible', 'Optimal Steroids - Received', 'Optimal Steroids - Did Not Receive', 'Optimal Steroids - % Received',
                       'MgSO4 - Eligible', 'MgSO4 - Received', 'MgSO4 - Did Not Receive', 'MgSO4 - % Received',
                       'Optimal MgSO4 - Eligible', 'Optimal MgSO4 - Received', 'Optimal MgSO4 - Did Not Receive', 'Optimal MgSO4 - % Received',
                       'Antibiotics - Eligible', 'Antibiotics - Received', 'Antibiotics - Did Not Receive', 'Antibiotics - % Received',
                       'Optimal Antibiotics - Eligible', 'Optimal Antibiotics - Received', 'Optimal Antibiotics - Did Not Receive', 'Optimal Antibiotics - % Received',
                       'Cord Management - Eligible', 'Cord Management - Received', 'Cord Management - Did Not Receive', 'Cord Management - % Received',
                       'Thermal Care - Eligible', 'Thermal Care - Received', 'Thermal Care - Did Not Receive', 'Thermal Care - % Received',
                       'Ventilation - Eligible', 'Ventilation - Received', 'Ventilation - Did Not Receive', 'Ventilation - % Received',
                       'Caffeine - Eligible', 'Caffeine - Received', 'Caffeine - Did Not Receive', 'Caffeine - % Received',
                       'EMBM - Eligible', 'EMBM - Received', 'EMBM - Did Not Receive', 'EMBM - % Received',
                       'Probiotics - Eligible', 'Probiotics - Received', 'Probiotics - Did Not Receive', 'Probiotics - % Received',
                       'Hydrocortisone - Eligible', 'Hydrocortisone - Received', 'Hydrocortisone - Did Not Receive', 'Hydrocortisone - % Received')) %>%
  write.csv('./output/matneo/matneo_sip_monthly_by_icb.csv')

# Monthly by HIN
df_matneo_sip %>% 
  group_by(hin_code, month) %>% 
  summarise(across(.cols = 4:45, .fns = \(x)sum(x , na.rm = TRUE)), .groups = 'keep') %>%
  ungroup() %>%
  mutate(place_rx_pct = place_rx/(place_rx + place_dnrx), .after = place_dnrx) %>%
  mutate(steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx), .after = steroids_dnrx) %>%
  mutate(steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx), .after = steroids_opt_dnrx) %>%
  mutate(mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx), .after = mgso4_dnrx) %>%
  mutate(mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx), .after = mgso4_opt_dnrx) %>%
  mutate(antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx), .after = antibiotics_dnrx) %>%
  mutate(antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx), .after = antibiotics_opt_dnrx) %>%
  mutate(cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx), .after = cord_mgt_dnrx) %>%
  mutate(thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx), .after = thermal_care_dnrx) %>%
  mutate(ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx), .after = ventilation_dnrx) %>%
  mutate(caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx), .after = caffeine_dnrx) %>%
  mutate(embm_rx_pct = embm_rx/(embm_rx + embm_dnrx), .after = embm_dnrx) %>%
  mutate(probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx), .after = probiotics_dnrx) %>%
  mutate(hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx), .after = hydrocortisone_dnrx) %>%
  rename_with(.fn = ~c('HIN', 'Month', 
                       'Place - Eligible', 'Place - Received', 'Place - Did Not Receive', 'Place - % Received',
                       'Steroids - Eligible', 'Steroids - Received', 'Steroids - Did Not Receive', 'Steroids - % Received',
                       'Optimal Steroids - Eligible', 'Optimal Steroids - Received', 'Optimal Steroids - Did Not Receive', 'Optimal Steroids - % Received',
                       'MgSO4 - Eligible', 'MgSO4 - Received', 'MgSO4 - Did Not Receive', 'MgSO4 - % Received',
                       'Optimal MgSO4 - Eligible', 'Optimal MgSO4 - Received', 'Optimal MgSO4 - Did Not Receive', 'Optimal MgSO4 - % Received',
                       'Antibiotics - Eligible', 'Antibiotics - Received', 'Antibiotics - Did Not Receive', 'Antibiotics - % Received',
                       'Optimal Antibiotics - Eligible', 'Optimal Antibiotics - Received', 'Optimal Antibiotics - Did Not Receive', 'Optimal Antibiotics - % Received',
                       'Cord Management - Eligible', 'Cord Management - Received', 'Cord Management - Did Not Receive', 'Cord Management - % Received',
                       'Thermal Care - Eligible', 'Thermal Care - Received', 'Thermal Care - Did Not Receive', 'Thermal Care - % Received',
                       'Ventilation - Eligible', 'Ventilation - Received', 'Ventilation - Did Not Receive', 'Ventilation - % Received',
                       'Caffeine - Eligible', 'Caffeine - Received', 'Caffeine - Did Not Receive', 'Caffeine - % Received',
                       'EMBM - Eligible', 'EMBM - Received', 'EMBM - Did Not Receive', 'EMBM - % Received',
                       'Probiotics - Eligible', 'Probiotics - Received', 'Probiotics - Did Not Receive', 'Probiotics - % Received',
                       'Hydrocortisone - Eligible', 'Hydrocortisone - Received', 'Hydrocortisone - Did Not Receive', 'Hydrocortisone - % Received')) %>%
  write.csv('./output/matneo/matneo_sip_monthly_by_hin.csv')

# Quarterly by Trust
df_matneo_sip %>% 
  group_by(org_code, financial_quarter) %>% 
  summarise(across(.cols = 4:45, .fns = \(x)sum(x , na.rm = TRUE)), .groups = 'keep') %>%
  ungroup() %>%
  mutate(place_rx_pct = place_rx/(place_rx + place_dnrx), .after = place_dnrx) %>%
  mutate(steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx), .after = steroids_dnrx) %>%
  mutate(steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx), .after = steroids_opt_dnrx) %>%
  mutate(mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx), .after = mgso4_dnrx) %>%
  mutate(mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx), .after = mgso4_opt_dnrx) %>%
  mutate(antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx), .after = antibiotics_dnrx) %>%
  mutate(antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx), .after = antibiotics_opt_dnrx) %>%
  mutate(cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx), .after = cord_mgt_dnrx) %>%
  mutate(thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx), .after = thermal_care_dnrx) %>%
  mutate(ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx), .after = ventilation_dnrx) %>%
  mutate(caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx), .after = caffeine_dnrx) %>%
  mutate(embm_rx_pct = embm_rx/(embm_rx + embm_dnrx), .after = embm_dnrx) %>%
  mutate(probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx), .after = probiotics_dnrx) %>%
  mutate(hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx), .after = hydrocortisone_dnrx) %>%
  rename_with(.fn = ~c('Trust', 'Financial Quarter', 
                       'Place - Eligible', 'Place - Received', 'Place - Did Not Receive', 'Place - % Received',
                       'Steroids - Eligible', 'Steroids - Received', 'Steroids - Did Not Receive', 'Steroids - % Received',
                       'Optimal Steroids - Eligible', 'Optimal Steroids - Received', 'Optimal Steroids - Did Not Receive', 'Optimal Steroids - % Received',
                       'MgSO4 - Eligible', 'MgSO4 - Received', 'MgSO4 - Did Not Receive', 'MgSO4 - % Received',
                       'Optimal MgSO4 - Eligible', 'Optimal MgSO4 - Received', 'Optimal MgSO4 - Did Not Receive', 'Optimal MgSO4 - % Received',
                       'Antibiotics - Eligible', 'Antibiotics - Received', 'Antibiotics - Did Not Receive', 'Antibiotics - % Received',
                       'Optimal Antibiotics - Eligible', 'Optimal Antibiotics - Received', 'Optimal Antibiotics - Did Not Receive', 'Optimal Antibiotics - % Received',
                       'Cord Management - Eligible', 'Cord Management - Received', 'Cord Management - Did Not Receive', 'Cord Management - % Received',
                       'Thermal Care - Eligible', 'Thermal Care - Received', 'Thermal Care - Did Not Receive', 'Thermal Care - % Received',
                       'Ventilation - Eligible', 'Ventilation - Received', 'Ventilation - Did Not Receive', 'Ventilation - % Received',
                       'Caffeine - Eligible', 'Caffeine - Received', 'Caffeine - Did Not Receive', 'Caffeine - % Received',
                       'EMBM - Eligible', 'EMBM - Received', 'EMBM - Did Not Receive', 'EMBM - % Received',
                       'Probiotics - Eligible', 'Probiotics - Received', 'Probiotics - Did Not Receive', 'Probiotics - % Received',
                       'Hydrocortisone - Eligible', 'Hydrocortisone - Received', 'Hydrocortisone - Did Not Receive', 'Hydrocortisone - % Received')) %>%
  write.csv('./output/matneo/matneo_sip_quarterly_by_trust.csv', row.names = FALSE)

# Quarterly by ICB
df_matneo_sip %>% 
  group_by(icb_code, financial_quarter) %>% 
  summarise(across(.cols = 4:45, .fns = \(x)sum(x , na.rm = TRUE)), .groups = 'keep') %>%
  ungroup() %>% 
  mutate(place_rx_pct = place_rx/(place_rx + place_dnrx), .after = place_dnrx) %>%
  mutate(steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx), .after = steroids_dnrx) %>%
  mutate(steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx), .after = steroids_opt_dnrx) %>%
  mutate(mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx), .after = mgso4_dnrx) %>%
  mutate(mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx), .after = mgso4_opt_dnrx) %>%
  mutate(antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx), .after = antibiotics_dnrx) %>%
  mutate(antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx), .after = antibiotics_opt_dnrx) %>%
  mutate(cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx), .after = cord_mgt_dnrx) %>%
  mutate(thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx), .after = thermal_care_dnrx) %>%
  mutate(ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx), .after = ventilation_dnrx) %>%
  mutate(caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx), .after = caffeine_dnrx) %>%
  mutate(embm_rx_pct = embm_rx/(embm_rx + embm_dnrx), .after = embm_dnrx) %>%
  mutate(probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx), .after = probiotics_dnrx) %>%
  mutate(hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx), .after = hydrocortisone_dnrx) %>%
  rename_with(.fn = ~c('ICB', 'Financial Quarter', 
                       'Place - Eligible', 'Place - Received', 'Place - Did Not Receive', 'Place - % Received',
                       'Steroids - Eligible', 'Steroids - Received', 'Steroids - Did Not Receive', 'Steroids - % Received',
                       'Optimal Steroids - Eligible', 'Optimal Steroids - Received', 'Optimal Steroids - Did Not Receive', 'Optimal Steroids - % Received',
                       'MgSO4 - Eligible', 'MgSO4 - Received', 'MgSO4 - Did Not Receive', 'MgSO4 - % Received',
                       'Optimal MgSO4 - Eligible', 'Optimal MgSO4 - Received', 'Optimal MgSO4 - Did Not Receive', 'Optimal MgSO4 - % Received',
                       'Antibiotics - Eligible', 'Antibiotics - Received', 'Antibiotics - Did Not Receive', 'Antibiotics - % Received',
                       'Optimal Antibiotics - Eligible', 'Optimal Antibiotics - Received', 'Optimal Antibiotics - Did Not Receive', 'Optimal Antibiotics - % Received',
                       'Cord Management - Eligible', 'Cord Management - Received', 'Cord Management - Did Not Receive', 'Cord Management - % Received',
                       'Thermal Care - Eligible', 'Thermal Care - Received', 'Thermal Care - Did Not Receive', 'Thermal Care - % Received',
                       'Ventilation - Eligible', 'Ventilation - Received', 'Ventilation - Did Not Receive', 'Ventilation - % Received',
                       'Caffeine - Eligible', 'Caffeine - Received', 'Caffeine - Did Not Receive', 'Caffeine - % Received',
                       'EMBM - Eligible', 'EMBM - Received', 'EMBM - Did Not Receive', 'EMBM - % Received',
                       'Probiotics - Eligible', 'Probiotics - Received', 'Probiotics - Did Not Receive', 'Probiotics - % Received',
                       'Hydrocortisone - Eligible', 'Hydrocortisone - Received', 'Hydrocortisone - Did Not Receive', 'Hydrocortisone - % Received')) %>%
  write.csv('./output/matneo/matneo_sip_quarterly_by_icb.csv', row.names = FALSE)

# Quarterly by HIN
df_matneo_sip %>% 
  group_by(hin_code, financial_quarter) %>% 
  summarise(across(.cols = 4:45, .fns = \(x)sum(x , na.rm = TRUE)), .groups = 'keep') %>%
  ungroup() %>%
  mutate(place_rx_pct = place_rx/(place_rx + place_dnrx), .after = place_dnrx) %>%
  mutate(steroids_rx_pct = steroids_rx/(steroids_rx + steroids_dnrx), .after = steroids_dnrx) %>%
  mutate(steroids_opt_rx_pct = steroids_opt_rx/(steroids_opt_rx + steroids_opt_dnrx), .after = steroids_opt_dnrx) %>%
  mutate(mgso4_rx_pct = mgso4_rx/(mgso4_rx + mgso4_dnrx), .after = mgso4_dnrx) %>%
  mutate(mgso4_opt_rx_pct = mgso4_opt_rx/(mgso4_opt_rx + mgso4_opt_dnrx), .after = mgso4_opt_dnrx) %>%
  mutate(antibiotics_rx_pct = antibiotics_rx/(antibiotics_rx + antibiotics_dnrx), .after = antibiotics_dnrx) %>%
  mutate(antibiotics_opt_rx_pct = antibiotics_opt_rx/(antibiotics_opt_rx + antibiotics_opt_dnrx), .after = antibiotics_opt_dnrx) %>%
  mutate(cord_mgt_rx_pct = cord_mgt_rx/(cord_mgt_rx + cord_mgt_dnrx), .after = cord_mgt_dnrx) %>%
  mutate(thermal_care_rx_pct = thermal_care_rx/(thermal_care_rx + thermal_care_dnrx), .after = thermal_care_dnrx) %>%
  mutate(ventilation_rx_pct = ventilation_rx/(ventilation_rx + ventilation_dnrx), .after = ventilation_dnrx) %>%
  mutate(caffeine_rx_pct = caffeine_rx/(caffeine_rx + caffeine_dnrx), .after = caffeine_dnrx) %>%
  mutate(embm_rx_pct = embm_rx/(embm_rx + embm_dnrx), .after = embm_dnrx) %>%
  mutate(probiotics_rx_pct = probiotics_rx/(probiotics_rx + probiotics_dnrx), .after = probiotics_dnrx) %>%
  mutate(hydrocortisone_rx_pct = hydrocortisone_rx/(hydrocortisone_rx + hydrocortisone_dnrx), .after = hydrocortisone_dnrx) %>%
  rename_with(.fn = ~c('HIN', 'Financial Quarter', 
                      'Place - Eligible', 'Place - Received', 'Place - Did Not Receive', 'Place - % Received',
                      'Steroids - Eligible', 'Steroids - Received', 'Steroids - Did Not Receive', 'Steroids - % Received',
                      'Optimal Steroids - Eligible', 'Optimal Steroids - Received', 'Optimal Steroids - Did Not Receive', 'Optimal Steroids - % Received',
                      'MgSO4 - Eligible', 'MgSO4 - Received', 'MgSO4 - Did Not Receive', 'MgSO4 - % Received',
                      'Optimal MgSO4 - Eligible', 'Optimal MgSO4 - Received', 'Optimal MgSO4 - Did Not Receive', 'Optimal MgSO4 - % Received',
                      'Antibiotics - Eligible', 'Antibiotics - Received', 'Antibiotics - Did Not Receive', 'Antibiotics - % Received',
                      'Optimal Antibiotics - Eligible', 'Optimal Antibiotics - Received', 'Optimal Antibiotics - Did Not Receive', 'Optimal Antibiotics - % Received',
                      'Cord Management - Eligible', 'Cord Management - Received', 'Cord Management - Did Not Receive', 'Cord Management - % Received',
                      'Thermal Care - Eligible', 'Thermal Care - Received', 'Thermal Care - Did Not Receive', 'Thermal Care - % Received',
                      'Ventilation - Eligible', 'Ventilation - Received', 'Ventilation - Did Not Receive', 'Ventilation - % Received',
                      'Caffeine - Eligible', 'Caffeine - Received', 'Caffeine - Did Not Receive', 'Caffeine - % Received',
                      'EMBM - Eligible', 'EMBM - Received', 'EMBM - Did Not Receive', 'EMBM - % Received',
                      'Probiotics - Eligible', 'Probiotics - Received', 'Probiotics - Did Not Receive', 'Probiotics - % Received',
                      'Hydrocortisone - Eligible', 'Hydrocortisone - Received', 'Hydrocortisone - Did Not Receive', 'Hydrocortisone - % Received')) %>%
  write.csv('./output/matneo/matneo_sip_quarterly_by_hin.csv', row.names = FALSE)

