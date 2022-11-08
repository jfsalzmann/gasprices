# Load all libraries

library(httr)
library(anytime)
library(magrittr)

# Introduce shortcuts

"%.%" = function(x,y){paste(x,y,sep = "")}

# Generate today's date

currentDate <- Sys.Date()
print(currentDate)

# DAX data: Update the URL reflecting today's date and generate a CSV

url = "https://query1.finance.yahoo.com/v7/finance/download/%5EGDAXI?period1=1510099200&period2=" %.% as.numeric(as.POSIXct(currentDate)) %.% "&interval=1d&events=history&includeAdjustedClose=true"
file = "data-orig/DAX.csv"
GET(url, write_disk(file, overwrite=TRUE))

# the dates represent the following

from_date <- anydate(1510099200)
to_date <- as.numeric(as.POSIXct(currentDate))