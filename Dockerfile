FROM node:lts

RUN apt-get update && apt-get install -y \
    ghostscript \
    graphicsmagick \
    libreoffice \
    poppler-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package*.json ./
RUN mkdir -p node-zerox/scripts
COPY node-zerox/scripts/install-dependencies.js node-zerox/scripts/
RUN npm install

COPY . .
RUN npm run build

CMD ["node"]
