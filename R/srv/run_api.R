#R/srv/run_api.R
library(plumber)

api <- plumber::plumb("/app/R/srv/service_pop.R")
api$run(host = "0.0.0.0", port = 16030)



