# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --no-audit --no-fund
COPY . .
RUN npm run build

# Run stage
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app .
EXPOSE 3000
# Wait for DB then migrate deploy then start
CMD sh -lc 'node -e "console.log(\"wait db...\")";   until nc -z ${DB_HOST:-postgres} ${DB_PORT:-5432}; do sleep 1; done;   npx prisma migrate deploy;   npm run start'
