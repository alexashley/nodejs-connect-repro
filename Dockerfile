FROM node:12.10.0-alpine

RUN apk add git

WORKDIR /usr/src/app

COPY middleware middleware
COPY stores stores
COPY keycloak.js .
COPY uuid.js .
COPY package.json .
COPY package-lock.json .
COPY example example

WORKDIR example

RUN npm link ../ && npm install

USER node

CMD ["node", "index.js"]
