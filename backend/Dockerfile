//
//  Dockerfile.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --omit=dev
COPY . .
EXPOSE 8787
CMD ["node", "server.js"]
