
library(rvest)
library(stringr)
library(tidyverse)
library(stringr)
library(tidyverse)
library(rvest)
library(janitor)
library(dplyr)
library(stopwords)
library(tm)
library(janeaustenr)
library(tidytext)
library(httr)
library(rjson)
library(jsonlite)
library(tibble)

url = "https://datenservice.tradinghub.eu/XmlInterface/getXML.ashx?ReportId=AggregatedConsumptionData&Start=01-06-2020&End=31-12-2022"
file = "data-orig/the.xml"

GET(url, write_disk(file, overwrite=TRUE))



parsed_url <- read_html("https://d.meteostat.net/app/proxy/stations/daily?station=10147&start=2016-10-01&end=2022-12-31")

json_text <- parsed_url %>%
  html_text()%>% 
  fromJSON()%>% 
  flatten()

df <-  as.data.frame(do.call(rbind, json_text))

df = df[-1,]


save(data_the,file="data-constr/data_the.RData")






