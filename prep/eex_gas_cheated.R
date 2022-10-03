library(tidyverse)
library(magrittr)

data558 = read_csv("data-constr/558.csv") %>% select(Gasprice,Gasday)

data = read_csv("data-constr/Gas Price_DE.csv", 
                         col_types = cols(Gasprice = col_double(),Gasday = col_date(format = "%d.%m.%y")))

data_merged = data %>% bind_rows(data558) %>% filter(!is.na(Gasday))

data_merged %>%
  write_csv("data-constr/gasprice_imputed.csv")