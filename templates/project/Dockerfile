FROM node:7

# build args
ARG PROJECT_MODE=staging
ARG PROJECT_BRANCH=develop
ARG PROJECT_GROUP=unknown
ARG PROJECT_NAME=unknown

# environment
ENV PROJECT_MODE=staging
ENV PROJECT_BRANCH=develop
ENV PROJECT_GROUP=unknown
ENV PROJECT_NAME=unknown

# upgrade system software
RUN echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" > /etc/apt/sources.list.d/debian-testing.list
RUN echo "Package: *\nPin: release a=testing\nPin-Priority: 100" > /etc/apt/preferences.d/debian-testing.pref
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y -t testing gcc g++

# copy application
COPY ./app /app
WORKDIR /app

# install dependencies
RUN npm install

# start application
CMD [ "npm", "start" ]
EXPOSE 3000
