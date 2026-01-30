#R/srv/run_api.R
library(plumber)

api <- plumber::plumb("/app/R/srv/service_pop.R")
api$run(host = "127.0.0.1", port = 16030)




