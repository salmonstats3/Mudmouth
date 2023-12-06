import Foundation
import NetworkExtension
import OSLog

func installVPN(_ completion: @escaping (_ error: Error?) -> Void) {
    let manager = NETunnelProviderManager()
    manager.localizedDescription = "Mudmouth"
    let proto = NETunnelProviderProtocol()
    proto.providerBundleIdentifier = "work.tkgstrator.proxy.PacketTunnel"
    proto.serverAddress = "Mudmouth"
    manager.protocolConfiguration = proto
    manager.isEnabled = true
    manager.saveToPreferences { error in
        completion(error)
    }
}

func loadVPN(_ completion: @escaping (_ manager: NETunnelProviderManager?) -> Void) {
    NETunnelProviderManager.loadAllFromPreferences { managers, error in
        if let error = error {
            fatalError("Failed to load VPN profile: \(error.localizedDescription)")
        }
        os_log(.info, "Load %d VPN profile", managers?.count ?? 0)
        let manager = managers?.first
        completion(manager)
    }
}

func startVPN(manager: NETunnelProviderManager, profile: Profile, certificate: [UInt8], privateKey: Data, _ completion: @escaping () -> Void) {
    manager.isEnabled = true
    manager.saveToPreferences { error in
        if let error = error {
            fatalError("Failed to enable VPN: \(error.localizedDescription)")
        }
        let (certificate, privateKey) = generateSiteCertificate(url: profile.url!, caCertificateData: certificate, caPrivateKeyData: privateKey)
        do {
            try manager.connection.startVPNTunnel(options: [
                NEVPNConnectionStartOptionUsername: "\(profile.directionEnum.rawValue):\(profile.url!)" as NSObject,
                NEVPNConnectionStartOptionPassword: "\(Data(certificate).base64EncodedString()):\(privateKey.base64EncodedString())" as NSObject
            ])
            completion()
        } catch {
            fatalError("Failed to start VPN: \(error.localizedDescription)")
        }
    }
}
