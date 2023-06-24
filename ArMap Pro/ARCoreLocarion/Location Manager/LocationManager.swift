//
//  LocationManager.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import CoreLocation

var userLocation: CLLocation = CLLocation()

protocol LocationManagerDelegate: AnyObject {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager,
                                          location: CLLocation)
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager,
                                         heading: CLLocationDirection,
                                         accuracy: CLLocationDirection)
}

extension LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager,
                                          location: CLLocation) { }

    func locationManagerDidUpdateHeading(_ locationManager: LocationManager,
                                         heading: CLLocationDirection,
                                         accuracy: CLLocationDirection) { }
}

/// Handles retrieving the location and heading from CoreLocation
/// Does not contain anything related to ARKit or advanced location
public class LocationManager: NSObject {
    weak var delegate: LocationManagerDelegate?

    private var locationManager: CLLocationManager?

    weak var currentLocation: CLLocation?

    private(set) public var heading: CLLocationDirection?
    private(set) public var headingAccuracy: CLLocationDirection?

    override init() {
        super.init()
     
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            switch locationManager!.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.locationManager!.distanceFilter = kCLDistanceFilterNone
                self.locationManager!.headingFilter = kCLHeadingFilterNone
                self.locationManager!.pausesLocationUpdatesAutomatically = false
                self.locationManager!.delegate = self
                self.locationManager!.startUpdatingHeading()
                self.locationManager!.startUpdatingLocation()

                self.locationManager!.requestWhenInUseAuthorization()

                self.currentLocation = self.locationManager!.location
                userLocation = locationManager!.location!
            case .notDetermined:
                locationManager?.requestWhenInUseAuthorization()
            case .denied:
                break
            case .restricted:
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    func requestAuthorization() {
        locationManager = CLLocationManager()
        if locationManager!.authorizationStatus == .authorizedAlways ||
            locationManager!.authorizationStatus == .authorizedWhenInUse {
            return
        }

        if locationManager!.authorizationStatus == .denied ||
            locationManager!.authorizationStatus == .restricted {
            return
        }

        locationManager?.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach {
            delegate?.locationManagerDidUpdateLocation(self, location: $0)
        }

        self.currentLocation = manager.location
        userLocation = locations.last!
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.headingAccuracy >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        headingAccuracy = newHeading.headingAccuracy

        delegate?.locationManagerDidUpdateHeading(self, heading: heading!, accuracy: newHeading.headingAccuracy)
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}
