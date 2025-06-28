FROM node:lts

RUN apt-get update && apt-get install -y \
    ghostscript \
    graphicsmagick \
    libreoffice \
    poppler-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Create scripts directory and copy install script
RUN mkdir -p node-zerox/scripts
COPY node-zerox/scripts/install-dependencies.js node-zerox/scripts/

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the project
RUN npm run build

# Create input and output directories
RUN mkdir -p /app/input /app/output

# Set entrypoint to use the CLI
ENTRYPOINT ["npm", "run", "cli", "--"]

# Default command shows help
CMD ["convert", "--help"]
