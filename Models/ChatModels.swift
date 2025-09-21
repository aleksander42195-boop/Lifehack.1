//
//  ChatModels.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//

import Foundation

// Chat message for UI
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var role: String
    var content: String

    init(id: UUID = UUID(), role: String, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}

// Data transfer objects for backend communication
struct ChatMessageDTO: Codable {
    let role: String
    let content: String

    init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

struct ChatRequest: Codable {
    let messages: [ChatMessageDTO]
    let model: String?
    let temperature: Double?

    init(messages: [ChatMessageDTO], model: String? = nil, temperature: Double? = nil) {
        self.messages = messages
        self.model = model
        self.temperature = temperature
    }
}

struct ChatResponse: Codable {
    let content: String
}
