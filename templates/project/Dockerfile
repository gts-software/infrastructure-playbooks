FROM node:7

# build args
ARG PROJECT_MODE=staging
ARG PROJECT_BRANCH=develop
ARG PROJECT_VERSION=unknown
ARG PROJECT_GROUP=unknown
ARG PROJECT_NAME=unknown

# environment
ENV PROJECT_MODE=staging
ENV PROJECT_BRANCH=develop
ENV PROJECT_VERSION=unknown
ENV PROJECT_GROUP=unknown
ENV PROJECT_NAME=unknown

# copy application
COPY ./app /app
WORKDIR /app

# install dependencies
RUN npm install

# start application
CMD [ "npm", "start" ]
EXPOSE 3000
