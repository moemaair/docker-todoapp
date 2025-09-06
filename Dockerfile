FROM node:20-alpine

# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install && \
    npm cache clean --force

# Copy source code
COPY . .

# Change ownership to non-root user
RUN chown -R nodeuser:nodejs /app
USER nodeuser

EXPOSE 3000
CMD [ "node", "server.js" ]