library(xml2)
library(XML)
library(tidyverse)
library(magrittr)
library(httr)

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


data = read_xml(file_adj) %>%
  xmlParse() %>%
  getNodeSet("//AggregatedConsumptionData") %>%
  xmlToDataFrame()
