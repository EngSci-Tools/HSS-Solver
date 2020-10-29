FROM node:13

WORKDIR /usr/src/app

ENV NODE_ENV=production

COPY package.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 80
CMD ["node", "server.mjs"]
