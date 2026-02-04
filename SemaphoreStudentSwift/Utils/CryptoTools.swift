//
//  CryptoTools.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/02/2026.
//

import CryptoKit
import SwiftUI


enum DeviceSignatureError: Error {
    case invalidPrivateKey
}


class CryptoTools {
    // MARK: Validation Appareil
    
    static func generateP256Keys() -> (publicKey: P256.Signing.PublicKey, privateKey: P256.Signing.PrivateKey) {
        let privateKey = P256.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        
        return (publicKey, privateKey)
    }
    
    static func loadPrivateKey(key privateKeyStr: String) -> P256.Signing.PrivateKey? {
        guard let data = Data(base64Encoded: privateKeyStr), let key = try? P256.Signing.PrivateKey(rawRepresentation: data) else { return nil }
        return key
    }
    
    static func loadPrivateKeyFromBase64Raw(_ base64: String) throws -> P256.Signing.PrivateKey {
        let cleaned = base64.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = Data(base64Encoded: cleaned, options: .ignoreUnknownCharacters) else {
            throw DeviceSignatureError.invalidPrivateKey
        }

        
        // rawRepresentation MUST be 32 bytes
        guard data.count == 32 else {
            throw DeviceSignatureError.invalidPrivateKey
        }

        return try P256.Signing.PrivateKey(rawRepresentation: data)
    }
    
    
    
    // MARK: Signature
    
    static func signSecuredMessage(
        key: P256.Signing.PrivateKey,
        method: String,
        path: String,
        studentId: UUID,
        deviceId: UUID,
        timestamp: Int64,
        body: Data,
        challenge: String
    ) throws -> String {
        
        let bodyHash = SHA256.hash(data: body)
        let bodyHashB64 = Data(bodyHash).base64EncodedString()
        
        let canonical = [
            method.uppercased(),
            path,
            studentId.uuidString.lowercased(),
            deviceId.uuidString.lowercased(),
            String(timestamp),
            bodyHashB64,
            challenge
        ].joined(separator: "\n")
        
        let signature = try key.signature(for: Data(canonical.utf8))
        return signature.derRepresentation.base64EncodedString()
    }
}
