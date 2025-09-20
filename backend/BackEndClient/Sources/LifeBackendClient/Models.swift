//
//  Models.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import Foundation

public struct ChatMessageDTO: Codable {
    public let role: String
    public let content: String
    public init(role: String, content: String) {
        self.role = role; self.content = content
    }
}

public struct ChatRequest: Codable {
    public let messages: [ChatMessageDTO]
    public let model: String?
    public let temperature: Double?
    public init(messages: [ChatMessageDTO], model: String? = nil, temperature: Double? = nil) {
        self.messages = messages; self.model = model; self.temperature = temperature
    }
}

public struct ChatResponse: Codable {
    public let content: String
}
