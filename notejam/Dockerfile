FROM node:alpine

WORKDIR /notejam
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["/bin/sh", "/notejam/start.sh"]
