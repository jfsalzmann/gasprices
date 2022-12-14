# Load all libraries

library(httr)
library(anytime)
library(magrittr)
library(dplyr)
library(imputeTS)

# Introduce shortcuts

"%.%" = function(x,y){paste(x,y,sep = "")}

# Generate today's date
startts = 1475269200
startdate = anydate(startts)
currentDate <- Sys.Date()
# print(currentDate)

# DAX data: Update the URL reflecting today's date and generate a CSV

url = "https://query1.finance.yahoo.com/v7/finance/download/%5EGDAXI?period1=" %.% startts %.% "&period2=" %.% as.numeric(as.POSIXct(currentDate)) %.% "&interval=1d&events=history&includeAdjustedClose=true"
file = "data-orig/DAX.csv"
GET(url, write_disk(file, overwrite=TRUE))

# the dates represent the following

# from_date <- anydate(1475269200)
# to_date <- as.numeric(as.POSIXct(currentDate))

# import our downloaded data


date_full = seq(startdate, currentDate, by="days") %>% data.frame(date = .)


DAX_data = read.csv("data-orig/DAX.csv")%>% 
  select(Date, Close) %>% 
  rename(date = Date, index = Close) %>% 
  mutate(date = as.Date(date))

DAX_data = date_full %>%
  left_join(DAX_data, by=c("date")) %>%
  mutate(index = na_interpolation(as.numeric(index)))
  

save(DAX_data, file = "data-constr/DAX_data.RData")


# data on gas prices

gas_data <- read_csv("data-orig/Dutch TTF Natural Gas Futures Historical Data.csv", col_types = cols(Date = col_date(format = "%m/%d/%Y"))) %>% 
  rename(date = Date, gasprice = Price)%>% 
  select(date, gasprice) %>% 
  mutate(date = as.Date(date))

gas_data = date_full %>%
  left_join(gas_data, by=c("date")) %>%
  mutate(gasprice = na_interpolation(as.numeric(gasprice)))

save(gas_data, file = "data-constr/gas_price_data.RData")



# data on GDP

Quarterly_GDP <- read_csv("data-orig/Quarterly_GDP.csv",col_types = cols(date = col_date(format = "%d.%m.%y")))%>% 
  mutate(date = as.Date(date)) %>%
  rename(gdp = "GDP(Quarterly)")

Quarterly_GDP = date_full %>%
  left_join(Quarterly_GDP, by=c("date")) %>%
  mutate(gdp = na_locf(as.numeric(gdp)))

save(Quarterly_GDP, file = "data-constr/Quarterly_GDP_data.RData")
  




# data on electricity prices

el_data <- read_csv("data-orig/German Power Baseload Calendar Month Futures Historical Data.csv",
                     col_types = cols(Date = col_date(format = "%m/%d/%Y"))) %>%
  rename(date = Date, elprice = Price)%>% 
  select(date, elprice) %>% 
  mutate(date = as.Date(date))

el_data = date_full %>%
  left_join(el_data, by=c("date")) %>%
  mutate(elprice = na_interpolation(as.numeric(elprice)))

save(el_data, file = "data-constr/el_price_data.RData")




# data on co2 prices

co2_data <- read_csv("data-orig/Carbon Emissions Futures Historical Data.csv",
                    col_types = cols(Date = col_date(format = "%m/%d/%Y"))) %>% 
  rename(date = Date, co2price = Price)%>% 
  select(date, co2price) %>% 
  mutate(date = as.Date(date))

co2_data = date_full %>%
  left_join(co2_data, by=c("date")) %>%
  mutate(co2price = na_interpolation(as.numeric(co2price)))

save(co2_data, file = "data-constr/co2_price_data.RData")
