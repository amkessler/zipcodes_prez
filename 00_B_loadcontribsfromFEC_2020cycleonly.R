# https://github.com/datasciencedojo/DataMiningFEC/blob/master/1%20itcont%20TXT%20to%20CSV.R


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
sample_amount = -1
# sample_amount = 1000
pol <- read.table(
  file="../fec_raw_ind_files/itcont_2020.txt",  # file to read in *****
  sep="|",  # pipe deliminated file
  quote="",  # parses in single quotes and escape slashes as text
  comment.char="",  # parse in pound symbol as text
  stringsAsFactors=FALSE,  # do not convert to factors
  nrow=sample_amount  # rows to read in
)

# 
# 
# # headers and information:
# # http://www.fec.gov/finance/disclosure/metadata/DataDictionaryContributionsbyIndividuals.shtml


pol.headers <- c(
  "CMTE_ID",
  "AMNDT_IND",
  "RPT_TP",
  "TRANSACTION_PGI",
  "IMAGE_NUM",
  "TRANSACTION_TP",
  "ENTITY_TP",
  "NAME",
  "CITY",
  "STATE",
  "ZIP_CODE",
  "EMPLOYER",
  "OCCUPATION",
  "TRANSACTION_DT",
  "TRANSACTION_AMT",
  "OTHER_ID",
  "TRAN_ID",
  "FILE_NUM",
  "MEMO_CD",
  "MEMO_TEXT",
  "SUB_ID"
)

pol.headers <- tolower(pol.headers)  # Formats headers
colnames(pol) <- pol.headers  # Assigns headers

head(pol)


# ############################
# # Output as feather file#
# ############################
# 

write_feather(pol, "../fec_raw_ind_files/ind2020.feather")



################
# LOADING IN SAVED FILE #####

pol_2020_all <- read_feather("../fec_raw_ind_files/ind2020.feather")


pol_2020_filtered <- pol_2020_all %>% 
  filter(cmte_id %in% c("P00006213",
                        "P00010520",
                        "P80001571",
                        "P00009290",
                        "P00009092",
                        "P00009621",
                        "P60007168",
                        "P00010454",
                        "P00006486",
                        "P00010298",
                        "P00010827",
                        "P80006117",
                        "P00009183",
                        "P00009423",
                        "P00010793",
                        "P00009795",
                        "P00009910",
                        "P00011239")
                       )




#output
write_feather(pol_filtered, "processed_data/pol_2020_filtered.feather")
