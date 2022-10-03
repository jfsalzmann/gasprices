### Maste Joint file


######### Join Weather
install.packages("tidyverse")
library("tidyverse")

data_constructed = read_csv("the_base.csv")
data_weather = read_csv("../data-orig/weather_changes/export.csv")


joinable_data <- data_weather %>%
  select(date, tavg, tmin, tmax)%>%
  rename(Gasday = date)

including_weather <- data_constructed %>%
  left_join(joinable_data)

############## Quartiles 


#dont_work <- including_weather %>% 
#  mutate(Quater =
#    case_when(
##    Gasday <= 2022-01-01 ~ "Q1",
 #   Gasday >= 2022-01-01 ~ "Q2",
#  ))


