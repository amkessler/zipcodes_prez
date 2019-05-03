library(tidyverse)
library(feather)
library(janitor)
library(lubridate)
library(writexl)
options(scipen = 999)

#run code in step 01 - loading polfiltered dataframe
source("01_analysis_of_selected_cmtes.R")

head(pol_filtered)

#bring in home state file
homestates <- read_csv("processed_data/homestates.csv")

#join 
joined <- inner_join(pol_filtered, homestates)

glimpse(joined)

#add columns for in/out of state contribution to each record
contribs <- joined %>% 
  mutate(
    out_of_state = if_else(state==home_state, "N", "Y")
  ) 

#analysis ####

#total in state out state dollars contributed
candidate_out_state <- contribs %>% 
  group_by(committee_name, cmte_id, out_of_state) %>% 
  summarise(sumcontribs = sum(transaction_amt)) %>% 
  mutate(percent = sumcontribs / sum(sumcontribs) * 100)

write_xlsx(candidate_out_state, "output/candidate_out_state.xlsx")
