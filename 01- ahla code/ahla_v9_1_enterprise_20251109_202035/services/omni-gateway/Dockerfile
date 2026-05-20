FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm i --no-audit --no-fund || true
COPY src ./src
EXPOSE 8060
CMD ["npm","start"]
