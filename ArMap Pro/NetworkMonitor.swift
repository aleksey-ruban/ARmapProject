//
//  NetworkMonitor.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 01.01.2022.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    
    public private(set) var connectionType: ConnectionType = .unknown
    
    private let server = Server.shared
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.getConnectionType(path)
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            server.getAllTags { [self] answer in
                if personalInfo.isOfflineLogin {
                    server.autoSignIn { answer in
                        if answer.success && answer.status == 200 {
                            self.stopMonitoring()
                        }
                    }
                }
            }
        }
        else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            server.getAllTags { [self] answer in
                if personalInfo.isOfflineLogin {
                    server.autoSignIn { answer in
                        if answer.success && answer.status == 200 {
                            self.stopMonitoring()
                        }
                    }
                }
            }
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            server.getAllTags { [self] answer in
                if personalInfo.isOfflineLogin {
                    server.autoSignIn { answer in
                        if answer.success && answer.status == 200 {
                            self.stopMonitoring()
                        }
                    }
                }
            }
        }
        else {
            connectionType = .unknown
        }
    }
}
