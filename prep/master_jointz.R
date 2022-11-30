library(tidyverse)
library(hablar)
library(lubridate)
library(magrittr)
library(imputeTS)

"%.%" = function(x,y){paste(x,y,sep = "")}

#setwd('/Users/finnkruger/Documents/GitHub/gasprices')

load('data-constr/final_weather_data.RData')
load('data-constr/DAX_data.RData')
load('data-constr/the_combined.Rdata')
load('data-constr/the_combined_rel.Rdata')
load('data-constr/Quarterly_GDP_data.Rdata')
load('data-constr/gas_price_data.Rdata')
load('data-constr/el_price_data.Rdata')
load('data-constr/co2_price_data.Rdata')


###### DATES & CYCLIC BEHAVIOR

startdate = as.Date("2017-11-01")
currentDate = Sys.Date()-1
date_full = seq(startdate, currentDate, by="days") %>% data.frame(date = .)

date_full %<>%
  mutate(dd_day = day(date),
         dd_month = month(date),
         dd_year = year(date),
         dd_weekday = wday(date),
         dd_week = week(date))

transform_sin = function(data){
  data %>% select_if(is.numeric) %>%
    rename_all(~ . %.% "_sin") %>% mutate_all(~sin(2*pi*./max(.))) %>% cbind(data) 
}

transform_cos = function(data){
  data %>% select(-contains("_sin")) %>% select_if(is.numeric) %>%
    rename_all(~ . %.% "_cos") %>% mutate_all(~cos(2*pi*./max(.))) %>% cbind(data) 
}

date_full %<>% transform_sin()
date_full %<>% transform_cos() %>%
  select(-contains("year_"))


####### MASTER JOINTZ, y, na omit


all_variables_combined = date_full %>%
  left_join(final_weather_data, by = 'date') %>%
  left_join(DAX_data, by = 'date') %>%
  left_join(data_the_combined, by = 'date') %>%
  left_join(data_the_combined_rel, by = 'date') %>%
  left_join(Quarterly_GDP, by = 'date') %>%
  left_join(gas_data, by = 'date') %>%
  left_join(el_data, by = 'date') %>%
  left_join(co2_data, by = 'date') %>%
  rename(y = total) %>%
  na.omit()


###### FEATURE ENGINEERING: ln,square,elasticity,infinity


transform_ln = function(data){
  data %>% select(-contains("__"),-date,-y) %>% select_if(is.numeric) %>%
    rename_all(~ . %.% "__ln") %>% mutate_all(~log(.+1-min(.))) %>% cbind(data) 
}

transform_sqrd = function(data){
  data %>% select(-contains("__"),-date,-y) %>% select_if(is.numeric) %>%
    rename_all(~ . %.% "__sqrd") %>% mutate_all(~ .^2) %>% cbind(data) 
}

transform_elas = function(data){
  data %>% select(-contains("__"),-date,-y) %>% select_if(is.numeric) %>%
    rename_all(~ . %.% "__elas") %>% mutate_all(~ 1/.^2) %>% cbind(data) 
}

all_variables_combined %<>% transform_ln()
all_variables_combined %<>% transform_sqrd()
all_variables_combined %<>% transform_elas() %>% 
  mutate(across(where(is.numeric), ~ ifelse(is.infinite(.x), max(s(.x))*1000, .x)))



######### LAG: 7 day w/ na interpolation

transform_lag = function(data,lag=1){
  data %>% select(-contains("____"),-date,-contains("dd_")) %>% select_if(is.numeric) %>%
    rename_all(~ . %.% "____lag" %.% lag) %>% mutate_all(~ lag(.,order_by = data$date)) %>% cbind(data) %>%
    mutate_all(~ na_interpolation(.))
}

all_variables_combined %<>% transform_lag(7)


all_variables_combined_midterm = all_variables_combined %>% select(-(contains("y_") & contains("____lag")))
all_variables_combined_ar = all_variables_combined %>% select(-((contains("Gas",ignore.case=FALSE) | contains("y_")) & !contains("____lag")))


save(all_variables_combined_midterm,file="data-constr/masters_jointz.RData")
all_variables_combined_midterm %>% write_csv("data-constr/masters_jointz.csv")

save(all_variables_combined,file="data-constr/masters_jointz_ar.RData")
all_variables_combined_ar %>% write_csv("data-constr/masters_jointz_ar.csv")




arima = all_variables_combined %>% 
  select(y,date) %>%
  transform_lag(1) %>% 
  transform_lag(2) %>% 
  transform_lag(3) %>% 
  transform_lag(4) %>% 
  transform_lag(5) %>% 
  transform_lag(6) %>% 
  transform_lag(7) #%>%
  #select(-date)

save(arima,file="data-constr/masters_arima.RData")

arima %>% write_csv("data-constr/masters_arima.csv")




sarima = all_variables_combined %>% 
  select(y,date,contains("dd_")) %>%
  transform_lag(1) %>% 
  transform_lag(2) %>% 
  transform_lag(3) %>% 
  transform_lag(4) %>% 
  transform_lag(5) %>% 
  transform_lag(6) %>% 
  transform_lag(7) #%>%
  #select(-date)

save(sarima,file="data-constr/masters_sarima.RData")

sarima %>% write_csv("data-constr/masters_sarima.csv")




### Actual_Arima


actual_sarima = all_variables_combined %>% 
  select(y,date) %>% mutate(date = as.numeric(date))


actual_sarima %>% write_csv("data-constr/actual_sarima.csv")



# ##### IGNORE EVERYTHING BELOW EXCEPT OTHERWISE told 
# data_constructed = read_csv("../data-constr/the_base.csv", col_types = cols(Gasday = col_date(format = "%d.%m.%y")))
# data_weather = read_csv("../data-orig/weather_changes/export.csv")
# 
# importIntoEnv()
# 
# joinable_data <- data_weather %>%
#   select(date, tavg, tmin, tmax)%>%
#   rename(Gasday = date)
# 
# 
# 
# including_weather <- data_constructed %>%
#   left_join(joinable_data)
# 
# final_weather_data <- df_hamburg%>%
#   left_join(df_berlin, by = 'date')%>%
#   left_join(df_munich, by = 'date')%>%
#   left_join(df_cologne, by = 'date')%>%
#   left_join(df_frankfurt, by = 'date')
# 
# 
# 
# 
# 
# 
# 
# 
# 
# ############## Quartiles 
# 
# data_gas_price = read_csv("../data-constr/gasprice_imputed.csv")
# 
# 
# including_weather_price = including_weather %>%
#   left_join(data_gas_price)
# 
# 
# #dont_work <- including_weather %>% 
# #  mutate(Quater =
# #    case_when(
# ##    Gasday <= 2022-01-01 ~ "Q1",
#  #   Gasday >= 2022-01-01 ~ "Q2",
# #  ))
# 
# 
# 
# including_weather_price %>%
#   write_csv("../data-constr/masters_jointz.csv")


# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=HGasSLPsyn_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=LGasSLPsyn_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=HGasSLPana_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=LGasSLPana_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=HGasRLMmT_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=LGasRLMmT_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=HGasRLMoT_rel)) + geom_line()
# all_variables_combined %>% filter(date > "2021-01-01") %>% ggplot(aes(x=date,y=LGasRLMoT_rel)) + geom_line()
