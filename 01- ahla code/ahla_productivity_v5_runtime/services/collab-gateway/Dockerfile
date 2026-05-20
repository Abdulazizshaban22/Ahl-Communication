FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm i --omit=dev || yarn --production
COPY . .
EXPOSE 1234
CMD ["npm","start"]