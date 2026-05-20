FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --no-audit --no-fund || true
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm","run","start"]
