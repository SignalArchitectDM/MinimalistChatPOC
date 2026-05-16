import CryptoKit
import Foundation

protocol KeyExchangeProtocol {
    func generatePrivateKey() -> Curve25519.KeyAgreement.PrivateKey
    func derivePublicKey(from privateKey: Curve25519.KeyAgreement.PrivateKey) -> Curve25519.KeyAgreement.PublicKey
    func performKeyExchange(ourPrivate: Curve25519.KeyAgreement.PrivateKey, peerPublic: Curve25519.KeyAgreement.PublicKey) -> SharedSecret?
    func deriveSymmetricKey(from sharedSecret: SharedSecret) -> SymmetricKey
}

class CryptoEngine: KeyExchangeProtocol {
    static let shared = CryptoEngine()
    private init() {}
    
    func generatePrivateKey() -> Curve25519.KeyAgreement.PrivateKey {
        return Curve25519.KeyAgreement.PrivateKey()
    }
    
    func derivePublicKey(from privateKey: Curve25519.KeyAgreement.PrivateKey) -> Curve25519.KeyAgreement.PublicKey {
        return privateKey.publicKey
    }
    
    func performKeyExchange(ourPrivate: Curve25519.KeyAgreement.PrivateKey, peerPublic: Curve25519.KeyAgreement.PublicKey) -> SharedSecret? {
        do {
            return try ourPrivate.sharedSecretFromKeyAgreement(with: peerPublic)
        } catch {
            return nil
        }
    }
    
    func deriveSymmetricKey(from sharedSecret: SharedSecret) -> SymmetricKey {
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "MinimalistChatSalt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
    }
    
    func simulateOfflineExchange() -> (ourPrivate: Curve25519.KeyAgreement.PrivateKey, peerPublic: Curve25519.KeyAgreement.PublicKey, symmetricKey: SymmetricKey?) {
        let actorA = generatePrivateKey()
        let actorB = generatePrivateKey()
        let bPub = derivePublicKey(from: actorB)
        guard let shared = performKeyExchange(ourPrivate: actorA, peerPublic: bPub) else {
            return (actorA, bPub, nil)
        }
        return (actorA, bPub, deriveSymmetricKey(from: shared))
    }
}