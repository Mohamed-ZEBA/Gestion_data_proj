# R/monitor/run_monitor.R
library(shiny)
library(here)

runApp(here::here("R", "monitor"), host = "0.0.0.0", port = 16031)
