FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm i --no-audit --no-fund
COPY src ./src
EXPOSE 8080
CMD ["npm","start"]
