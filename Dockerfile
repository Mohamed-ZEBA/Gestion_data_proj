FROM trestletech/plumber

WORKDIR /app

COPY R /app/R
RUN mkdir -p /app/storage

EXPOSE 16030

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["Rscript /app/R/srv/run_api.R & Rscript /app/R/update_every_5s.R"]
