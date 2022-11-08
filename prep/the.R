library(xml2)
library(XML)
library(tidyverse)
library(magrittr)
library(httr)
library(readr)

"%.%" = function(x,y){paste(x,y,sep = "")}

url = "https://datenservice.tradinghub.eu/XmlInterface/getXML.ashx?ReportId=AggregatedConsumptionData&Start=01-06-2020&End=31-12-2022"
file_orig = "data-orig/the.xml"
file_adj = "data-constr/the.xml"

GET(url, write_disk(file_orig, overwrite=TRUE))

cat("\n", file = file_orig, append = TRUE)

readLines(file_orig) %>%
  str_replace_all(
    pattern = ' xmlns="urn:schemas-microsoft-com:sql:SqlRowSet1"', 
    replace = "") %>%
  str_replace_all(
    pattern = '</AggregatedConsumptionData>$', 
    replace = "</ACD>") %>%
  str_replace_all(
    pattern = '<AggregatedConsumptionData><xsd:', 
    replace = "<ACD><xsd:") %>%
  writeLines(file_adj)


is_all_numeric = function(x) {
  !any(is.na(suppressWarnings(as.numeric(na.omit(x))))) & is.character(x)
}

data_the = read_xml(file_adj) %>%
  xmlParse() %>%
  getNodeSet("//AggregatedConsumptionData") %>%
  xmlToDataFrame() %>% 
  select(-Status,-Unit) %>%
  filter(Gasday <= Sys.Date()-1) %>%
  mutate_if(is_all_numeric,as.numeric) %>%
  mutate(Gasday = as.Date(Gasday), total = HGasSLPsyn+LGasSLPsyn+HGasSLPana+LGasSLPsyn+HGasRLMmT+LGasRLMmT+HGasRLMoT+LGasRLMoT)

save(data_the,file="data-constr/the.RData")




url = "https://www.tradinghub.eu/Portals/0/Archiv%20GASPOOL/verbrauchsdaten-gesamt%5b1%5d.csv?ver=BY7wJ3jSq7CqEWv7Qtka1w%3d%3d"
file_orig = "data-orig/the_gaspool.csv"
GET(url, write_disk(file_orig, overwrite=TRUE))
data_the_gaspool = read_delim(file_orig, delim = ";", escape_double = FALSE, col_types = cols(Datum = col_date(format = "%d.%m.%Y")), trim_ws = TRUE)
names(data_the_gaspool) = c(
  "Gasday","HGasSLPsyn", "LGasSLPsyn", "HGasSLPana", "LGasSLPana", "HGasRLMmT", "LGasRLMmT", "HGasRLMoT","LGasRLMoT"
)
data_the_gaspool %<>% mutate(total = HGasSLPsyn+LGasSLPsyn+HGasSLPana+LGasSLPsyn+HGasRLMmT+LGasRLMmT+HGasRLMoT+LGasRLMoT)
save(data_the_gaspool,file="data-constr/the_gaspool.RData")



url = "https://www.tradinghub.eu/Portals/0/Archiv%20NCG/AggregatedConsumptionData[1].csv?ver=QvIUEDkSVZrhNqQ9YEsu8w%3d%3d"
file_orig = "data-orig/the_ncg.csv"
GET(url, write_disk(file_orig, overwrite=TRUE))
data_the_ncg = read_delim(file_orig, delim = ";", escape_double = FALSE, col_types = cols(DayOfUse = col_date(format = "%d.%m.%Y")), trim_ws = TRUE) %>%
  rename(Gasday = DayOfUse) %>%
  select(-contains('Unit'),-Status) %>%
  filter(Gasday >= '2016-10-01') %>% 
  mutate(total = HGasSLPsyn+LGasSLPsyn+HGasSLPana+LGasSLPsyn+HGasRLMmT+LGasRLMmT+HGasRLMoT+LGasRLMoT)
save(data_the_ncg,file="data-constr/the_ncg.RData")



data_the_historic = data_the_gaspool %>% left_join(data_the_ncg, by = c("Gasday")) %>% mutate(
  HGasSLPsyn = HGasSLPsyn.x + HGasSLPsyn.y,
  LGasSLPsyn = LGasSLPsyn.x + LGasSLPsyn.y,
  HGasSLPana = HGasSLPana.x + HGasSLPana.y,
  LGasSLPana = LGasSLPana.x + LGasSLPana.y,
  HGasRLMmT = HGasRLMmT.x + HGasRLMmT.y,
  LGasRLMmT = LGasRLMmT.x + LGasRLMmT.y,
  HGasRLMoT = HGasRLMoT.x + HGasRLMoT.y,
  LGasRLMoT = LGasRLMoT.x + LGasRLMoT.y,
  total = total.x + total.y
) %>% select(-contains('.x'),-contains('.y'))

save(data_the_historic,file="data-constr/the_historic.RData")




data_the_combined = data_the_historic %>% bind_rows(data_the) %>% rename(date = Gasday)
save(data_the_combined,file="data-constr/the_combined.RData")



data_the_combined_rel = data_the_combined %>%
  mutate(across(where(is.numeric), ~ .x/total)) %>%
  setNames(names(.) %.% "_rel") %>%
  rename(date = date_rel)
save(data_the_combined_rel,file="data-constr/the_combined_rel.RData")