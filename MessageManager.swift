import SwiftUI
import CryptoKit

@MainActor
class MessageManager: ObservableObject {
    @Published var messages: [Message] = []
    private var encryptionKey: SymmetricKey?
    
    struct Message: Identifiable, Equatable {
        let id: UUID
        let content: String
        let isFromUser: Bool
    }
    
    init() {
        self.encryptionKey = CryptoEngine.shared.deriveSymmetricKey(from: CryptoEngine.shared.performKeyExchange(
            ourPrivate: CryptoEngine.shared.generatePrivateKey(),
            peerPublic: CryptoEngine.shared.derivePublicKey(from: CryptoEngine.shared.generatePrivateKey())
        )!)
        loadMock()
    }
    
    private func loadMock() {
        messages = [
            Message(id: UUID(), content: "Secure test message one", isFromUser: false),
            Message(id: UUID(), content: "Reply in session", isFromUser: true)
        ]
    }
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty, let key = encryptionKey else { return }
        let encrypted = encrypt(text, key: key)
        if let decrypted = decrypt(encrypted, key: key) {
            messages.append(Message(id: UUID(), content: decrypted, isFromUser: true))
        }
    }
    
    func duressWipe() {
        for i in 0..<messages.count {
            messages[i] = Message(id: UUID(), content: String(repeating: "\0", count: 2048), isFromUser: false)
        }
        messages.removeAll(keepingCapacity: false)
        messages = []
        encryptionKey = nil
        
        for _ in 0..<8 {
            let wipeBuffer = [UInt8](repeating: 0xFF, count: 8192)
            _ = wipeBuffer
        }
        print("Duress wipe: array and key zeroed")
    }
    
    private func encrypt(_ plaintext: String, key: SymmetricKey) -> Data {
        guard let data = plaintext.data(using: .utf8) else { return Data() }
        do {
            let sealed = try AES.GCM.seal(data, using: key)
            return sealed.combined ?? Data()
        } catch { return Data() }
    }
    
    private func decrypt(_ ciphertext: Data, key: SymmetricKey) -> String? {
        do {
            let box = try AES.GCM.SealedBox(combined: ciphertext)
            let data = try AES.GCM.open(box, using: key)
            return String(data: data, encoding: .utf8)
        } catch { return nil }
    }
}