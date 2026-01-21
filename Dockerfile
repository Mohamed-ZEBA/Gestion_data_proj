FROM rocker/shiny:4.3.2

# 1) Forcer un chemin de libs unique (system)
ENV R_LIBS_SITE=/usr/local/lib/R/site-library
ENV R_LIBS_USER=/usr/local/lib/R/site-library

# 2) Installer proprement (outil standard des images rocker)
RUN install2.r --error --skipinstalled plumber ggplot2

# 3) Forcer .libPaths() pour TOUS les runs R (API + Shiny + updater)
RUN echo "local({ .libPaths('/usr/local/lib/R/site-library') })" >> /usr/local/lib/R/etc/Rprofile.site

WORKDIR /app
COPY R /app/R
COPY start.sh /app/start.sh

RUN sed -i 's/\r$//' /app/start.sh && chmod +x /app/start.sh
RUN mkdir -p /app/storage

EXPOSE 16030 16031
CMD ["/app/start.sh"]
