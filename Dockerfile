FROM node:20-alpine

# Create app directory
WORKDIR /var/www/todoapp
COPY package*.json ./

# Install app dependencies
RUN npm install

# Bundle app source

COPY . .

RUN npm run build

EXPOSE 3000
CMD [ "node", "server.js" ]