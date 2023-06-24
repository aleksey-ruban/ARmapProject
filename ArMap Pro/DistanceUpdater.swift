//
//  DistanceUpdater.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 08.05.2022.
//

import Foundation
import CoreLocation

class DistanceUpdater {
    
    static let shared = DistanceUpdater()
    
    private init() {}
    
    var delegate: DistanceUpdateProtocol?
    
    private var isTracking: Bool = false
    private var delta: Array<Int> = [0, 0, 0, 0, 0]
    private var previousLocation: CLLocation?
    private var sleepTime: Double = 0.5
    
    func startTracking() {
        if !self.isTracking {
            self.tracking()
            self.isTracking = true
            self.updateInfo()
            self.sleepTime = 0.5
        }
    }
    
    func tracking() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            self.delegate?.sendPosition()
            if !self.isTracking {
                timer.invalidate()
            }
        }
    }
    
    func updateInfo() {
        Timer.scheduledTimer(withTimeInterval: sleepTime, repeats: true) { (timer) in
            self.delegate?.changeInfo()
            if !self.isTracking {
                timer.invalidate()
            }
        }
    }
    
    func stopTraking() {
        self.isTracking = false
    }
    
    public func newLocation(location: CLLocation?) {
        guard let location = location else {
            return
        }
        
        for i in 0...3 {
            delta[i] = delta[i + 1]
        }
        delta[4] = Int(previousLocation?.distance(from: location) ?? 0)
        previousLocation = location
        //print(delta)
        
        analyzeDelta()
    }
    
    func analyzeDelta() {
        let middleValue = Double(delta.reduce(0, +)) / Double(delta.count)
        let time = 5.0 * sqrt(80.0 / pow(middleValue, 3))
        if time > 10.0 {
            sleepTime = 10.0
        } else {
            sleepTime = time
        }
        //print(middleValue, sleepTime)
    }
    
    func updateNow() {
        self.delegate?.changeInfo()
    }

}
