library(tidyverse)
library(magrittr)

library(jsonlite)
library(data.table)

url = readLines("https://www.powernext.com/data-feed/132735/139/558")

json = fromJSON(url[0])

#%>% as.data.frame
