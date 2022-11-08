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

parsed_url_hamburg <- read_html("https://d.meteostat.net/app/proxy/stations/daily?station=10147&start=2016-10-01&end=2022-12-31")
parsed_url_frankfurt <- read_html("https://d.meteostat.net/app/proxy/stations/daily?station=D1424&start=2016-10-01&end=2022-12-31")
parsed_url_berlin <- read_html("https://d.meteostat.net/app/proxy/stations/daily?station=10389&start=2016-10-01&end=2022-12-31")
parsed_url_munich <- read_html("https://d.meteostat.net/app/proxy/stations/daily?station=10865&start=2016-10-01&end=2022-12-31")
parsed_url_cologne <- read_html("https://d.meteostat.net/app/proxy/stations/daily?station=D2968&start=2016-10-01&end=2022-12-31")


#Hamburg

df_hamburg <- parsed_url_hamburg %>%
  html_text()%>%
  fromJSON()

df_hamburg <- df_hamburg$data  

colnames(df_hamburg) <- paste("HH", colnames(df_hamburg), sep = "_")

df_hamburg <- rename(df_hamburg, date = HH_date)


#Frankfurt

df_frankfurt <- parsed_url_frankfurt %>%
  html_text()%>%
  fromJSON()

df_frankfurt <- df_frankfurt$data  

colnames(df_frankfurt) <- paste("FF", colnames(df_frankfurt), sep = "_")

df_frankfurt <- rename(df_frankfurt, date = FF_date)


# Berlin 

df_berlin <- parsed_url_berlin %>%
  html_text()%>%
  fromJSON()

df_berlin <- df_berlin$data  

colnames(df_berlin) <- paste("B", colnames(df_berlin), sep = "_")

df_berlin <- rename(df_berlin, date = B_date)



# München 

df_munich <- parsed_url_munich %>%
  html_text()%>%
  fromJSON()

df_munich <- df_munich$data  

colnames(df_munich) <- paste("M", colnames(df_munich), sep = "_")

df_munich <- rename(df_munich, date = M_date)


# cologne

df_cologne <- parsed_url_cologne %>%
  html_text()%>%
  fromJSON()

df_cologne <- df_cologne$data  

colnames(df_cologne) <- paste("K", colnames(df_cologne), sep = "_")

df_cologne <- rename(df_cologne, date = K_date)


### creating a big table with all data points 


final_weather_data <- df_hamburg%>%
  left_join(df_berlin, by = 'date')%>%
  left_join(df_munich, by = 'date')%>%
  left_join(df_cologne, by = 'date')%>%
  left_join(df_frankfurt, by = 'date')
  

#####
save(final_weather_data,file="../data-constr/final_weather_data.RData")






