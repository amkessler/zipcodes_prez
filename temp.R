library(tidyverse)
library(feather)

getwd()

df <- read_feather("../fec_raw_ind_files/ind2008.feather")
