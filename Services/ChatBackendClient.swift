//
//  ChatBackendClient.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import Foundation

final class ChatBackendClient {
    private let baseURL: URL
    private let clientToken: String

    init(baseURL: String, clientToken: String) {
        self.baseURL = URL(string: baseURL)!
        self.clientToken = clientToken
    }

    func send(messages: [ChatMessage], model: String? = nil, temperature: Double? = nil) async throws -> String {
        let dto = messages.map { ChatMessageDTO(role: $0.role, content: $0.content) }
        let payload = ChatRequest(messages: dto, model: model, temperature: temperature)
        let data = try JSONEncoder().encode(payload)

        var req = URLRequest(url: baseURL.appendingPathComponent("/v1/chat"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(clientToken, forHTTPHeaderField: "X-Client-Token")
        req.httpBody = data

        let (body, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let text = String(data: body, encoding: .utf8) ?? ""
            throw NSError(domain: "ChatBackendError", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: text])
        }
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: body)
        return decoded.content
    }
}
