//
//  package.json.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//{
"name": "lifehack-backend",
"version": "1.0.0",
"type": "module",
"main": "server.js",
"scripts": {
  "dev": "node server.js",
  "start": "NODE_ENV=production node server.js"
},
"dependencies": {
  "cors": "^2.8.5",
  "dotenv": "^16.4.5",
  "express": "^4.19.2",
  "helmet": "^7.1.0",
  "express-rate-limit": "^7.4.0",
  "zod": "^3.23.8",
  "openai": "^4.58.1"
}
}
