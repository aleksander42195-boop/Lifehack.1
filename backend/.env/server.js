//
//  server.js.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//# Kopier denne filen til .env og fyll inn verdiene

# OpenAI API key (den du genererte på platform.openai.com)
OPENAI_API_KEY=sk-...

# Hemmelig klient-token (brukes mellom iOS-app og backend, ikke del offentlig)
CLIENT_TOKEN=replace-with-a-long-random-string

# Backend-port (default 8787)
PORT=8787

# Tillatte domener (for CORS)
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import OpenAI from 'openai';

const app = express();

// --- Last inn miljøvariabler fra .env ---
const apiKey = process.env.OPENAI_API_KEY;
const clientToken = process.env.CLIENT_TOKEN;
const port = process.env.PORT || 8787;

// --- Sjekk at nøkkel finnes ---
if (!apiKey) {
  console.error("❌ OPENAI_API_KEY mangler i .env");
  process.exit(1);
}

// --- OpenAI-klient med nøkkel fra .env ---
const openai = new OpenAI({ apiKey });

// --- Middleware ---
app.use(helmet());
app.use(express.json());
app.use(cors());

// Enkel klient-autentisering
app.use((req, res, next) => {
  const token = req.header("X-Client-Token");
  if (!token || token !== clientToken) {
    return res.status(401).json({ error: "Unauthorized" });
  }
  next();
});

// --- Endepunkt for ChatGPT ---
app.post("/v1/chat", async (req, res) => {
  try {
    const { messages } = req.body;
    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages,
    });
    const text = response.choices[0]?.message?.content ?? "";
    res.json({ content: text });
  } catch (err) {
    console.error("OpenAI-feil:", err);
    res.status(500).json({ error: "OpenAI error" });
  }
});

// --- Start server ---
app.listen(port, () => {
  console.log(`✅ Backend kjører på http://localhost:${port}`);
});
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
