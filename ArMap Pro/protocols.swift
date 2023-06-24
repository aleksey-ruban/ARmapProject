//
//  protocols.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 31.12.2021.
//

import Foundation

protocol ServerProtocol {
    func closeViewControllersWithUnlogin()
    func allTagsWasRecieved()
    func accountWasRecieved()
}

protocol DistanceUpdateProtocol {
    func sendPosition()
    func changeInfo()
}
