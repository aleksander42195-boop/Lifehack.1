import Foundation

/// Representerer en melding i chatten
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: ChatRole
    var content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: ChatRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

/// Roller i samtalen (bruker vs. AI-assistent)
enum ChatRole: String, Codable {
    case user
    case assistant
}

/// Payload som sendes til backend når brukeren skriver noe
struct ChatRequest: Codable {
    let messages: [ChatMessageDTO]
}

/// Responsen backend sender tilbake
struct ChatResponse: Codable {
    let reply: String
}

/// DTO (Data Transfer Object) for meldinger som sendes til/fra backend
struct ChatMessageDTO: Codable {
    let role: String
    let content: String

    init(from message: ChatMessage) {
        self.role = message.role.rawValue
        self.content = message.content
    }
}
