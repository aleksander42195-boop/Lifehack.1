//
//  CoachingView.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 19/09/2025.
//import SwiftUI

struct CoachingView: View {
    @EnvironmentObject private var appConfig: AppConfig
    @State private var history: [ChatMessage] = [
        ChatMessage(role: "system", content: "You are Lifehack Coach. Be concise, practical, and supportive.")
    ]
    @State private var input: String = ""
    @State private var isSending = false
    @State private var errorText: String?

    private func client() -> ChatBackendClient {
        ChatBackendClient(baseURL: appConfig.backendURL, clientToken: appConfig.clientToken)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(history) { msg in ChatBubble(message: msg) }
                    }.padding()
                }
                if let err = errorText {
                    Text(err).foregroundStyle(.red).padding(.horizontal)
                }
                HStack(alignment: .bottom, spacing: 8) {
                    TextEditor(text: $input)
                        .frame(minHeight: 44, maxHeight: 120)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))
                    Button {
                        Task { await send() }
                    } label: { isSending ? AnyView(ProgressView()) : AnyView(Image(systemName: "paperplane.fill")) }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
                }.padding()
            }
            .navigationTitle("Coaching")
        }
    }

    @MainActor
    private func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        errorText = nil
        input = ""
        history.append(ChatMessage(role: "user", content: text))
        isSending = true
        do {
            let reply = try await client().send(messages: history, model: "gpt-4o-mini", temperature: 0.7)
            history.append(ChatMessage(role: "assistant", content: reply))
        } catch {
            errorText = "Could not send message. \(error.localizedDescription)"
        }
        isSending = false
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.role == "assistant" {
                Text(message.content)
                    .padding(10)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Spacer()
            } else if message.role == "user" {
                Spacer()
                Text(message.content)
                    .padding(10)
                    .background(.green.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text(message.content).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}
