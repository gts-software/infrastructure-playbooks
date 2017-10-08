FROM node:7

# build args
ARG PROJECT_MODE=development
ARG PROJECT_BRANCH=develop
ARG PROJECT_GROUP=unknown
ARG PROJECT_NAME=unknown

# environment
ENV PROJECT_MODE=${PROJECT_MODE}
ENV PROJECT_BRANCH=${PROJECT_BRANCH}
ENV PROJECT_GROUP=${PROJECT_GROUP}
ENV PROJECT_NAME=${PROJECT_NAME}

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
