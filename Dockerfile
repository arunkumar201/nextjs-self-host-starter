FROM node:18-alpine as base

# Stage 1: Install dependencies
FROM base AS deps
WORKDIR /app
# Globally install the package manager pnpm.
RUN npm i -g pnpm
# Copy the package.json and pnpm-lock.yaml files to the working directory in the container.
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

# Stage 2: Build the application
FROM base AS builder
WORKDIR /app
# Globally install the package manager pnpm.
RUN npm i -g pnpm

COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm run build

# Stage 3: Production server
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
