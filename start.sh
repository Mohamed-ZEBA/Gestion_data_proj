#!/bin/sh
echo "=== START CONTAINER ==="

echo "Starting updater..."
Rscript /app/R/update_every_5s.R &

echo "Starting API..."
Rscript /app/R/srv/run_api.R &

echo "Starting Shiny..."
Rscript /app/R/monitor/run_monitor.R

wait
