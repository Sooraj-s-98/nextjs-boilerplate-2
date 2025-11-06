# 1️⃣ Build stage
FROM node:22-alpine AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first (for better caching)
COPY package*.json ./
# or if you use yarn:
# COPY yarn.lock package.json ./

# Install dependencies
RUN npm install
# or: RUN yarn install --frozen-lockfile

# Copy rest of the app
COPY . .

# Build the Next.js app
RUN npm run build
# or: RUN yarn build

# 2️⃣ Production stage
FROM node:22-alpine AS runner

# Set NODE_ENV to production
ENV NODE_ENV=production

WORKDIR /app

# Copy only the necessary output and dependencies from builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package*.json ./
# or: COPY --from=builder /app/package.json /app/yarn.lock ./

# Install only production dependencies
RUN npm install --omit=dev
# or: RUN yarn install --production --frozen-lockfile

# Expose Next.js port
EXPOSE 3000

# Start Next.js
CMD ["npm", "run", "start"]
