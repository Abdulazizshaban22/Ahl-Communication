FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm i --no-audit --no-fund || true
COPY src ./src
EXPOSE 8090
CMD ["npm","start"]
