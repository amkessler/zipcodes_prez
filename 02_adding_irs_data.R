# IRS data source: https://www.irs.gov/statistics/soi-tax-stats-individual-income-tax-statistics-2016-zip-code-data-soi
library(tidyverse)
library(janitor)
library(Hmisc)

#run code in step 01
source("01_analysis_of_selected_cmtes.R")


irszips_allcols <- read_csv("processed_data/16zpallagi.csv", 
                                   col_types = cols(STATEFIPS = col_character(), 
                                                    zipcode = col_character()))

irszips_allcols <- irszips_allcols %>% 
  clean_names()

names(irszips_allcols)


#looking for any 4 digit zips by mistake?
irszips_allcols %>% 
  filter(str_length(zipcode)==4)

#fix 4-digit zips to add back preceding 0
zipscorrected <- if_else(str_length(irszips_allcols$zipcode)==4, paste0("0", irszips_allcols$zipcode), irszips_allcols$zipcode)
irszips_allcols$zipscorrected <- zipscorrected
#check cols
irszips_allcols %>% 
  select(zipcode, zipscorrected) %>% 
  filter(zipcode != zipscorrected)
#make replacement
irszips_allcols$zipcode <- irszips_allcols$zipscorrected



#select just AGI columns
irs_zips_agi <- irszips_allcols %>% 
  select(statefips, state, zipcode, agi_stub, total_returns = n1, agi_value = a00100)

#take out the state-wide totals, zip = 0. Also remove "other" designation, 99999
irs_zips_agi <- irs_zips_agi %>% 
  filter(zipcode != "0",
         zipcode != "99999")

head(irs_zips_agi)


#looking for any 4 digit zips by mistake?
irs_zips_agi %>% 
  filter(str_length(zipcode)==4)



#create column translating agi_stub to description, per documentation
# 1 = $1 under $25,000
# 2 = $25,000 under $50,000
# 3 = $50,000 under $75,000
# 4 = $75,000 under $100,000
# 5 = $100,000 under $200,000
# 6 = $200,000 or more

irs_zips_agi <- irs_zips_agi %>% 
  mutate(
    agi_stubcategory = case_when(
      agi_stub == 1 ~ "under $25K",
      agi_stub == 2 ~ "$25K to under $50K",
      agi_stub == 3 ~ "$50K to under $75K",
      agi_stub == 4 ~ "$75K to under $100K",
      agi_stub == 5 ~ "$100K to under $200K",
      agi_stub == 6 ~ "$200K or more",
      TRUE ~ "other"
    )
  )


#sum up all agi/returns for each zip
irs_zips_agi_grouped <- irs_zips_agi %>% 
  group_by(zipcode) %>% 
  summarise(num_returns = sum(total_returns), total_agi_value = sum(agi_value)) %>% 
  mutate(avg_agi = total_agi_value/num_returns*1000)
         
head(irs_zips_agi_grouped)

#rank by agi
irs_zips_agi_grouped <- irs_zips_agi_grouped %>% 
  mutate(avg_agi_rank = rank(desc(avg_agi))) %>% 
  arrange(avg_agi_rank)



# #add percentiles
# describe(irs_zips_agi_grouped)
# 
# irs_zips_agi_grouped <- irs_zips_agi_grouped %>% 
#   mutate(
#     ntile_agi = ntile(total_agi_value, 5),
#     ntile_ratio = ntile(ratio_val_to_num, 5)
#   )
# 
# # percent_rank(irs_zips_agi_grouped$total_agi_value)
# 
# #average within our groups
# irs_zips_agi_grouped %>% 
#   group_by(ntile_agi) %>% 
#   summarise(mean(total_agi_value))
# 
# #average within our groups
# irs_zips_agi_grouped %>% 
#   group_by(ntile_ratio) %>% 
#   summarise(mean(ratio_val_to_num))




saveRDS(irs_zips_agi_grouped, "processed_data/irs_zips_agi_grouped.rds")


### joining zip code description data from commercial zip database
zip_codes_database <- read_csv("zip-codes-database/zip-codes-database-STANDARD.csv")

zip_codes_database <- zip_codes_database %>% 
  clean_names() %>% 
  select(zipcode = zip_code, city, state) 

zip_codes_database <- zip_codes_database %>% 
  distinct()

#join
zips_joined1 <- left_join(irs_zips_agi_grouped, zip_codes_database) 



### JOINING TO CONTRIBUTION DATA FROM STEP 01 ####


irs_zips <- zips_joined1 %>% 
  rename(zip5 = zipcode)

allzips_w_agi <- inner_join(allzips, irs_zips)

# Check whether any zips not joining?
irs_zips %>% 
  count(state) 

irs_zips %>% 
  filter(is.na(state))


#export
write_xlsx(allzips_w_agi, "output/allzips_w_agi.xlsx")


