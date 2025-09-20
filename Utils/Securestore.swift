//
//  Securestore.swift
//  Lifehack
//
//  Created by Aleksander Blindheim on 18/09/2025.
//import Foundation
import Security

enum SecureStore {
    static func save(key: String, data: Data) -> Bool { return true }
    static func load(key: String) -> Data? { return nil }
}
