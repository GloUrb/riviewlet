# On commence par définir l'image sur laquelle va se baser la notre
FROM rocker/r2u:jammy

# On précise quelques infos qui permettrons d'identifier l'image
LABEL org.opencontainers.image.authors="Lise Vaudor <lise.vaudor@ens-lyon.fr>"
LABEL org.opencontainers.image.source="https://github.com/lvaudor/riviewlet"

# On peut éventuellement générer des locales supplémentaires si notre appli utilise d'autres langues que l'anglais
RUN locale-gen fr_FR.UTF-8

# On liste maintenant toutes les dépendances R à installer
RUN Rscript -e 'install.packages("shiny")'
RUN Rscript -e 'install.packages("leaflet")'
RUN Rscript -e 'install.packages("changepoint")'
RUN Rscript -e 'install.packages("dplyr")'
RUN Rscript -e 'install.packages("ggplot2")'
RUN Rscript -e 'install.packages("readr")'
RUN Rscript -e 'install.packages("lubridate")'
RUN Rscript -e 'install.packages("tidyr")'
RUN Rscript -e 'install.packages("stringr")'
RUN Rscript -e 'install.packages("rlang")'
RUN Rscript -e 'install.packages("sf")'
# On copie l'arborescence de fichiers dans un dossier app à la racine de l'image. Ce sera le working directory des containers lancés avec notre image
RUN mkdir /app
ADD . /app
WORKDIR /app

RUN Rscript -e 'remotes::install_local()'

# On détermine le port qui sera exposé (attention à bien fixer le port sur lequel votre appli écoute, cf. ci-dessus)
EXPOSE 3838

# Pour plus de sécurité, on fait en sorte que les containers ne se lancent pas avec l'utilisateur "root", mais avec un utilisateur "app" dédié
RUN groupadd -g 1010 app && useradd -c 'app' -u 1010 -g 1010 -m -d /home/app -s /sbin/nologin app
USER app

# Enfin, on précise la commande qui permet de lancer notre appli. C'est cette commande qui sera lancée par défaut par tout nouveau container lancé avec notre image
CMD  ["R", "-e", "shiny::runApp('.', port=3838, host='0.0.0.0')"]

