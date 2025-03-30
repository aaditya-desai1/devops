# Use an official Node.js runtime as the base image
FROM node:18  

# Set the working directory inside the container
WORKDIR /app  

# Copy package.json and install dependencies
COPY package.json .  
RUN npm install  

# Copy the rest of the app’s code
COPY . .  

# Expose the port the app runs on
EXPOSE 3000  

# Start the app
CMD ["node", "server.js"]
