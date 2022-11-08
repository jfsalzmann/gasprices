### Maste Joint file


######### Join Weather
install.packages("tidyverse")
library("tidyverse")



setwd('../data-constr')

getwd()

load('final_weather_data.RData')
load('DAX_data.RData')
load('the_combined.Rdata')
load('the_combined_rel.Rdata')


all_variables_combined <- final_weather_data%>%
  left_join(DAX_data, by = 'date')


all_variables_combined$date <- as.Date(all_variables_combined$date, "%Y-%m-%d")
data_the_combined$date <- as.Date(data_the_combined$date , "%Y-%m-%d")

class(all_variables_combined$date)
class(data_the_combined$date)

all_variables_combined <- all_variables_combined%>%
  left_join(data_the_combined, by = 'date')%>%
  left_join(data_the_combined_rel, by = 'date')



















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
