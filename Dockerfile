FROM node:22-alpine AS test

WORKDIR /usr/app

COPY ./dist ./dist
COPY ./package*.json ./
RUN npm install --only=production


EXPOSE 4011

CMD ["node", "dist/main.js"]