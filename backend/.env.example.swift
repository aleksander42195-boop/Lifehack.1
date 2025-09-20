//
//  .env.example.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//# Kopier denne filen til .env og fyll inn verdiene

# OpenAI API key (den du genererte på platform.openai.com)
OPENAI_API_KEY=sk-...# Kopier denne filen til .env og fyll inn verdiene

# OpenAI API key (den du genererte på platform.openai.com)
OPENAI_API_KEY=sk-...

# En hemmelig nøkkel for din app/klient.
# Denne legges inn i iOS-appen (Settings-fanen).
CLIENT_TOKEN=replace-with-a-long-random-string

# Backend-port
PORT=8787

# Tillatte domener (komma-separert). På dev kan du la stå tom eller skrive localhost.
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000

# En hemmelig nøkkel for din app/klient.
# Denne legges inn i iOS-appen (Settings-fanen).
CLIENT_TOKEN=replace-with-a-long-random-string

# Backend-port
PORT=8787

# Tillatte domener (komma-separert). På dev kan du la stå tom eller skrive localhost.
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
# Kopier denne filen til .env og fyll inn verdiene

# OpenAI API key (den du genererte på platform.openai.com)
OPENAI_API_KEY=sk-...

# Hemmelig klient-token (brukes mellom iOS-app og backend, ikke del offentlig)
CLIENT_TOKEN=replace-with-a-long-random-string

# Backend-port (default 8787)
PORT=8787

# Tillatte domener (for CORS)
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
# === OpenAI API Key ===
# Bytt ut 'DIN_API_NØKKEL' med din ekte nøkkel fra OpenAI Dashboard.
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
# === Client Token ===
# En hemmelig streng du finner på selv.
# Appen din må sende denne som header:  X-Client-Token
CLIENT_TOKEN=min-klient-hemmelighet

# === Server Port ===
# Porten backend kjører på. Standard: 8787
PORT=8787

# === CORS Origins ===
# Hvilke adresser får lov å koble seg til backend.
# I starten kan du sette localhost.
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
CLIENT_TOKEN=min-LuciaiBhg2025-123
                            ## iOS/Watch
                            Åpne `ios-app/LifehackApp.xcodeproj` i Xcode. Aktiver HealthKit/App Groups i Capabilities. Kjør.

                            ## Swift Package
                            # === OpenAI API Key ===
                            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
                            # === Client Token ===
                            CLIENT_TOKEN=LuciaiBhg2025

                            # === Server Port ===
                            PORT=http://:172.20.10.8:8787

                            # === CORS Origins ===
                            ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
let baseUrl=http://:172.20.10.8:8787
npm run dev_t
// server.js
app.get('/health', (req,res)=>res.send('ok'));
app.listen(8787, '0.0.0.0', () => {
  console.log('API on http://<MAC_IP>:8787');
});
