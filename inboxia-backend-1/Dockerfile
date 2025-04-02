# Stage 1: Build
FROM node:16-alpine AS builder
WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:16-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --only=production
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/main.js"]
