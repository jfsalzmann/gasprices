library("tidyverse")



load('data-constr/final_weather_data.RData')
load('data-constr/DAX_data.RData')
load('data-constr/the_combined.Rdata')
load('data-constr/the_combined_rel.Rdata')
load('data-constr/Quarterly_GDP_data.Rdata')
load('data-constr/gas_price_data.Rdata')
load('data-constr/el_price_data.Rdata')
load('data-constr/co2_price_data.Rdata')


startdate = as.Date("2017-11-01")
currentDate = Sys.Date()-1
date_full = seq(startdate, currentDate, by="days") %>% data.frame(date = .)


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


save(all_variables_combined,file="data-constr/masters_jointz.RData")

all_variables_combined %>%
  write_csv("data-constr/masters_jointz.csv")













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
