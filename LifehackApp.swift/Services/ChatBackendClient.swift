//
//  Untitled.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//
import Foundation

/// Snakker med din Node/Express-backend (proxy til OpenAI).
/// Leser baseURL og clientToken fra AppConfig (via SettingsView).
final class ChatBackendClient {

    private let baseURL: URL
    private let clientToken: String
    private let session: URLSession

    init(baseURL: String, clientToken: String, session: URLSession = .shared) {
        guard let url = URL(string: baseURL) else {
            preconditionFailure("Ugyldig baseURL: \(baseURL)")
        }
        self.baseURL = url
        self.clientToken = clientToken
        self.session = session
    }

    /// Sender hele samtalehistorikken til backend og returnerer AI-svaret som tekst.
    /// - Parameters:
    ///   - messages: Lokale meldinger som skal mappes til DTO før sending.
    ///   - model: Valgfri modell-override (backend har default).
    ///   - temperature: Valgfri temperatur.
    func send(
        messages: [ChatMessage],
        model: String? = nil,
        temperature: Double? = nil
    ) async throws -> String {

        // Map til DTO-formatet backend forventer
        let dtoMessages: [ChatMessageDTO] = messages.map {
            ChatMessageDTO(role: $0.role.rawValue, content: $0.content)
        }

        // Hvis du bruker ChatRequest/ChatResponse slik vi definerte i Models:
        let payload = ChatRequest(messages: dtoMessages)

        // Bygg request
        var request = URLRequest(url: baseURL.appendingPathComponent("/v1/chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(clientToken, forHTTPHeaderField: "X-Client-Token")
        request.timeoutInterval = 30

        // JSON-body
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(payload)

        // Kjør nettverkskallet
        let (data, response) = try await session.data(for: request)

        // Valider HTTP-status
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "ChatBackendClient", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Ugyldig serverrespons"])
        }

        guard (200..<300).contains(http.statusCode) else {
            let serverText = String(data: data, encoding: .utf8) ?? "Ukjent serverfeil"
            throw NSError(domain: "ChatBackendClient", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: serverText])
        }

        // Dekode respons
        // Merk: Hvis backend svarer { content: "..." } bruk ChatResponse(content: String)
        // Hvis den svarer { reply: "..." } bruk ChatResponse(reply: String)
        struct ChatResponseCompat: Decodable {
            let content: String?
            let reply: String?
        }

        let decoded = try JSONDecoder().decode(ChatResponseCompat.self, from: data)
        if let content = decoded.content {
            return content
        } else if let reply = decoded.reply {
            return reply
        } else {
            throw NSError(domain: "ChatBackendClient", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Tomt svar fra server"])
        }
    }
}
