FROM elixir:1.10.1

#ARG build_env
#
## DEV ENVIRONMENT
#ENV MIX_ENV $build_env
#ENV DB_HOST postgres
#ENV DB_USER postgres
#ENV DB_PASSWORD postgres
#
## INSTALL DEPENDENCIES
#RUN apt-get update && apt-get install -y lsb-release
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
#RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update -qq && apt-get install -y  \
#    build-essential \
#    apt-transport-https \
#    wget \
    nodejs \
    postgresql-client \
#    curl \
    inotify-tools \
#    groff \
#    python3-pip \
    vim
#
#RUN pip3 install awscli --upgrade
## CONFIGURE DIRECTORIES OF PROJECT
RUN mkdir /tft_helper
WORKDIR /tft_helper
#
#COPY ./docker/bin/* /usr/local/bin/
COPY . /tft_helper
#
## INSTALL PHOENIX DEPENDENCIES (--force not to be interactive)
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.4.11 --force

RUN npm i --prefix assets
#
#
#RUN chmod u+x /usr/local/bin/prod_build.sh && /usr/local/bin/prod_build.sh $build_env
#
# APPLICATION PORT
EXPOSE 4000
