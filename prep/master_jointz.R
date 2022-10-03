### Maste Joint file


######### Join Weather
install.packages("tidyverse")
library("tidyverse")

data_constructed = read_csv("../data-constr/the_base.csv", col_types = cols(Gasday = col_date(format = "%d.%m.%y")))
data_weather = read_csv("../data-orig/weather_changes/export.csv")


joinable_data <- data_weather %>%
  select(date, tavg, tmin, tmax)%>%
  rename(Gasday = date)

including_weather <- data_constructed %>%
  left_join(joinable_data)






############## Quartiles 

data_gas_price = read_csv("../data-constr/gasprice_imputed.csv")


including_weather_price = including_weather %>%
  left_join(data_gas_price)


#dont_work <- including_weather %>% 
#  mutate(Quater =
#    case_when(
##    Gasday <= 2022-01-01 ~ "Q1",
 #   Gasday >= 2022-01-01 ~ "Q2",
#  ))



including_weather_price %>%
  write_csv("../data-constr/masters_jointz.csv")
