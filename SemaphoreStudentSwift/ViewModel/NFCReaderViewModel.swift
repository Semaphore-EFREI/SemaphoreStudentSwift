//
//  NFCReaderViewModel.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/07/2025.
//

import SwiftUI
import Combine
import CoreNFC


class NFCReaderViewModel: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    
    @Published var nfcMessage: String = "Aucun tag lu"
    private var session: NFCNDEFReaderSession?
    
    // On stocke la continuation pour y répondre plus tard
    private var continuation: CheckedContinuation<String, Never>?
    
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            nfcMessage = "NFC non disponible sur cet appareil"
            continuation?.resume(returning: "NFC non disponible")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Approchez un tag NFC"
        session?.begin()
    }
    
    /// Version awaitable
    func scanForNFCMessage() async -> String {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.beginScanning()
        }
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.nfcMessage = "Session annulée : \(error.localizedDescription)"
            self.continuation?.resume(returning: "Erreur NFC : \(error.localizedDescription)")
            self.continuation = nil
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = "Aucun message trouvé"
        if let record = messages.first?.records.first,
           let payload = String(data: record.payload, encoding: .utf8) {
            result = "Tag lu: \(payload)"
        }
        DispatchQueue.main.async {
            self.nfcMessage = result
            self.continuation?.resume(returning: result)
            self.continuation = nil
        }
    }
}
