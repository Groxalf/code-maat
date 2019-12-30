FROM node:12.14.0-alpine3.11

ENV PORT=8001

RUN mkdir /app
WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY . .

CMD ["npm", "start"]
