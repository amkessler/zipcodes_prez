### NOTE: COMBINED HUGE COMBINED FILE OF 2008-2018 INDIVIDUAL FEC CONTRIBS BELOW NOT INCLUDED IN REPO
# HOWEVER IF YOU WANT TO START AT SCRIPT 01, THE FILE CAN BE DOWNLOADED HERE:
# https://www.dropbox.com/s/cxfanwzurj1qvzf/ind_2008_thru_2018_all.feather?dl=1


library(data.table)
library(tidyverse)
library(feather)
options(scipen = 999)

###############################################
# Read in individual contributions list       #
###############################################

# Sample from the individual contribution dataset
#   The dataset is 1.7GB so sampling is necessary
#   for now.



# Set to -1 for 100% of the data
# sample_amount = -1
# # sample_amount = 1000
# pol <- read.table(
#   file="../fec_raw_ind_files/itcont_2018.txt",  # file to read in *****
#   sep="|",  # pipe deliminated file
#   quote="",  # parses in single quotes and escape slashes as text
#   comment.char="",  # parse in pound symbol as text
#   stringsAsFactors=FALSE,  # do not convert to factors
#   nrow=sample_amount  # rows to read in
# )
# 
# 
# # headers and information:
# # http://www.fec.gov/finance/disclosure/metadata/DataDictionaryContributionsbyIndividuals.shtml


# pol.headers <- c(
#   "CMTE_ID",
#   "AMNDT_IND",
#   "RPT_TP",
#   "TRANSACTION_PGI",
#   "IMAGE_NUM",
#   "TRANSACTION_TP",
#   "ENTITY_TP",
#   "NAME",
#   "CITY",
#   "STATE",
#   "ZIP_CODE",
#   "EMPLOYER",
#   "OCCUPATION",
#   "TRANSACTION_DT",
#   "TRANSACTION_AMT",
#   "OTHER_ID",
#   "TRAN_ID",
#   "FILE_NUM",
#   "MEMO_CD",
#   "MEMO_TEXT",
#   "SUB_ID"
# )
# pol.headers <- tolower(pol.headers)  # Formats headers
# colnames(pol) <- pol.headers  # Assigns headers
# # 
# # head(pol)
# 
# 
# 
# 
# 
# ############################
# # Output as feather file#
# ############################
# 
# # write_feather(pol, "../fec_raw_ind_files/ind2018.feather")
# 
# 
# 
# 
# #load from saved ####
# 
# pol08 <- read_feather("../fec_raw_ind_files/ind2008.feather")
# pol10 <- read_feather("../fec_raw_ind_files/ind2010.feather")
# pol12 <- read_feather("../fec_raw_ind_files/ind2012.feather")
# pol14 <- read_feather("../fec_raw_ind_files/ind2014.feather")
# pol16 <- read_feather("../fec_raw_ind_files/ind2016.feather")
# pol18 <- read_feather("../fec_raw_ind_files/ind2018.feather")
# 
# pol_combined_all <- rbind(pol08,
#                           pol10,
#                           pol12,
#                           pol14,
#                           pol16,
#                           pol18)
# 
# 
# write_feather(pol_combined_all, "../fec_raw_ind_files/ind_2008_thru_2018_all.feather")


################


### SEE ABOVE FOR DOWNLOAD LOCATION OF THIS FILE

pol_combined_all <- read_feather("../fec_raw_ind_files/ind_2008_thru_2018_all.feather")


pol_filtered <- pol_combined_all %>% 
  filter(cmte_id %in% c("C00431353",
                        "C00508416",
                        "C00571919",
                        "C00413914",
                        "C00500843",
                        "C00540500",
                        "C00411330",
                        "C00497396")
                       )

#output
write_feather(pol_filtered, "processed_data/pol_filtered.feather")
