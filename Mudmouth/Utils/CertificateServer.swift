//
//  CertificateServer.swift
//  Mudmouth
//
//  Created by Xie Zhihao on 2023/9/29.
//

import Crypto
import Foundation
import NIO
import NIOHTTP1
import SwiftASN1
import X509
import OSLog

class CertificateHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let httpData = unwrapInboundIn(data)
        guard case .head = httpData else {
            return
        }
        let (certificate, _) = loadCertificate()
        guard let certificate = certificate else {
            // Send 404 to downstream.
            let headers = HTTPHeaders([("Content-Length", "0")])
            let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .notFound, headers: headers)
            context.write(self.wrapOutboundOut(.head(head)), promise: nil)
            context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
            return
        }
        // Send certificate to downstream.
        let serializedCertificate = serializeCertificate(certificate)
        let base64EncodedCertificate = Data(serializedCertificate).base64EncodedString()
        let cer = "-----BEGIN CERTIFICATE-----\n\(base64EncodedCertificate.components(withMaxLength: 64).joined(separator: "\n"))\n-----END CERTIFICATE-----\n"
        let headers = HTTPHeaders([("Content-Length", cer.count.formatted()), ("Content-Type", "application/x-x509-ca-cert")])
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        let buffer = context.channel.allocator.buffer(string: cer)
        let body = HTTPServerResponsePart.body(.byteBuffer(buffer))
        context.writeAndFlush(self.wrapOutboundOut(body), promise: nil)
        os_log(.info, "Send certificate to downstream")
    }
}

func runCertificateServer() {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ServerBootstrap(group: group)
        .serverChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
        .childChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
        .childChannelInitializer({ channel in
            channel.pipeline.configureHTTPServerPipeline()
                .flatMap { _ in
                    channel.pipeline.addHandler(CertificateHandler())
                }
        })
    bootstrap.bind(to: try! SocketAddress(ipAddress: "127.0.0.1", port: 16836)).whenComplete { result in
        switch result {
        case .success:
            os_log("Bind certificate server")
            break
        case .failure(let failure):
            fatalError("Failed to bind certificate server \(failure)")
        }
    }
}