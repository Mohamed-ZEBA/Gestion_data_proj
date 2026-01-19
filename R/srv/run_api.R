library(plumber)
library(here)

pr(here::here("R", "srv", "service_pop.R")) %>%
  pr_run(host = "0.0.0.0", port = 16030)
