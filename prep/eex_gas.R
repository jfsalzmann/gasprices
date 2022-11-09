library(tidyverse)
library(magrittr)

library(jsonlite)

library(rvest)
library(xml2)
library(anytime)

# url = readLines("https://www.powernext.com/data-feed/132735/139/558")


url = "https://www.powernext.com/data-feed/1467707/819/17"
file_orig = "data-orig/eex_ngp.json"
GET(url, write_disk(file_orig, overwrite=TRUE))
cat("\n", file = file_orig, append = TRUE)


data_eex_ngp = read_html(file_orig) %>%
  html_text() %>%
  fromJSON() %$% values$data[[1]] %>%
  rename(date = x, ngp = y) %>%
  select(-name) %>%
  mutate(date = anydate(date/1000))


load('data-constr/gas_price_data.Rdata')


gas_data %<>%
  left_join(data_eex_ngp, by="date") %>%
  filter(date <= (Sys.Date()-1)) %>%
  mutate(gasprice_adj = case_when(is.na(ngp) ~ gasprice, TRUE ~ ngp)) %>%
  select(-ngp)


save(gas_data, file = "data-constr/gas_price_data.RData")
