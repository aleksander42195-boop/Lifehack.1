//
//  ChatBackendClient.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import Foundation

public final class LifehackBackendClient {
    private let baseURL: URL
    private let clientToken: String

    public init(baseURL: String, clientToken: String) {
        self.baseURL = URL(string: baseURL)!
        self.clientToken = clientToken
    }

    public func send(messages: [ChatMessageDTO], model: String? = nil, temperature: Double? = nil) async throws -> String {
        let payload = ChatRequest(messages: messages, model: model, temperature: temperature)
        let data = try JSONEncoder().encode(payload)

        var req = URLRequest(url: baseURL.appendingPathComponent("/v1/chat"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(clientToken, forHTTPHeaderField: "X-Client-Token")
        req.httpBody = data

        let (body, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let text = String(data: body, encoding: .utf8) ?? ""
            throw NSError(domain: "LifehackBackendClient", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: text])
        }
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: body)
        return decoded.content
    }
}# backend/.env

# OpenAI API-nøkkel (bytt ut med din ekte nøkkel fra OpenAI dashboard)
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxx

# Client Token (en hemmelig streng du finner på selv)
CLIENT_TOKEN=LuciaiBhg2025-123

# Port (kan stå på 8787 som standard)
PORT=8787
