# Use the official Node.js 18 slim image
FROM node:18-slim AS base

# Install build dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-distutils \
    build-essential \
    libffi-dev \
 && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of your application code
COPY . .

# Build the Next.js application
RUN npm run build

# Expose port 3000
EXPOSE 3000

# Start the Next.js application
CMD ["npm", "run", "dev"]
