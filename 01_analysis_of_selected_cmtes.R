library(tidyverse)
library(feather)
library(janitor)
library(lubridate)
library(writexl)
options(scipen = 999)

# 1 - load combined filtered ind historical records 2008-2018 from saved file:
pol_filtered <- read_feather("processed_data/pol_filtered.feather")



#check formats of columns
glimpse(pol_filtered)

#convert date to date format
pol_filtered$transaction_dt <- mdy(pol_filtered$transaction_dt)

#add year, month, zip5 columns
pol_filtered <- pol_filtered %>% 
  mutate(
    transaction_year = year(transaction_dt),
    transaction_month = month(transaction_dt),
    zip5 = str_sub(zip_code, 1, 5)
  )

#check formats of columns again
glimpse(pol_filtered)


#bring in lookup table of committee names to add
prezcmtes <- read_csv("processed_data/prezcmtes.csv")


#join main data table to lookup to add cmte names
pol_filtered <- left_join(pol_filtered, prezcmtes)

#move committee name column to be first
pol_filtered <- pol_filtered %>% 
  select(committee_name, everything())

#check to see if any cmte ids not matched with names
pol_filtered %>% 
  count(cmte_id, committee_name)



#********************
#### ANALYSIS #####

#records per year
pol_filtered %>% 
  count(transaction_year)

#number, sums per year
pol_filtered %>% 
  group_by(transaction_year) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt))


#by committee and year
pol_filtered %>% 
  group_by(committee_name, transaction_year) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt))


#by committee, zip code (5 digits)
pol_filtered %>% 
  group_by(committee_name, zip5) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt)) %>% 
  arrange(committee_name, desc(sumcontribs))


#by committee, zip code --- TOP N for each committee
pol_filtered %>% 
  group_by(committee_name, zip5) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt)) %>% 
  top_n(n = 100, wt = sumcontribs) %>% 
  arrange(committee_name, desc(sumcontribs))

#save results to new object
topzips <- pol_filtered %>% 
  group_by(committee_name, zip5) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt)) %>% 
  top_n(n = 100, wt = sumcontribs) %>% 
  arrange(committee_name, desc(sumcontribs))

#export file
write_xlsx(topzips, "output/topzips_2008thru2018.xlsx")


#this time ALL zip codes not just top n
#save results to new object
allzips <- pol_filtered %>% 
  group_by(committee_name, zip5) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt)) 

#export file
write_xlsx(allzips, "output/allzips_2008to2018.xlsx")


#looking zips with any missing zeros?
topzips %>% 
  filter(committee_name == "Elizabeth for MA, Inc.")




#ALL zip codes by YEAR for each candidate
allzips_bycand_and_year <- pol_filtered %>% 
  group_by(committee_name, transaction_year, zip5) %>% 
  summarise(numcontribs = n(), sumcontribs = sum(transaction_amt)) 

#export file
# write_xlsx(allzips_bycand_and_year, "output/allzips_cand_and_year_2008to2018.xlsx")

