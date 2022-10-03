library(tidyverse)
library(magrittr)


data = read_csv("data-constr/getXML.csv")

colnames(data)

data %<>% select(Gasday,HGasSLPsyn,HGasSLPana,LGasSLPsyn,LGasSLPana,HGasRLMmT,LGasRLMmT,HGasRLMoT,LGasRLMoT,Status,Unit) %>%
  filter(!is.na(HGasRLMmT)) %>%
  mutate(y = HGasSLPsyn+HGasSLPana+LGasSLPsyn+LGasSLPana+HGasRLMmT+LGasRLMmT+HGasRLMoT+LGasRLMoT) %>%
  write_csv("data-constr/the_base.csv")
