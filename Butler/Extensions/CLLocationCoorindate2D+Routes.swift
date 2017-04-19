//
//  CLLocationCoorindate2D+Routes.swift
//  Butler
//
//  Created by blackbriar on 10/4/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//
import Foundation
import MapKit
import CoreLocation

extension CLLocationCoordinate2D {

    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
//    func closestLocation(_ locations: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
//        var closestLocation: (distance: Double, coordinates: CLLocationCoordinate2D)?
//        
//        for loc in locations {
//            let distance = round(self.location.distance(from: loc.location)) as Double
//            if closestLocation == nil {
//                closestLocation = (distance, loc)
//            } else {
//                if distance < closestLocation!.distance {
//                    closestLocation = (distance, loc)
//                }
//            }
//        }
//        return closestLocation?.coordinates
//    }
//    
//    func locationsSortedByDistanceFromPreviousLocation(_ locations: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
//        // take in an array and a starting location
//        // using the previous closestLocation function, build a distance-sorted array
//        // return that array
//        var sortedLocation = [CLLocationCoordinate2D]()
//        var newLocations = locations
//        //print("LOCATIONS \(newLocations)")
//        var previousLocation = self
////        print("STARTING LOCATION \(previousLocation)")
//        sortedLocation.append(previousLocation)
//        newLocations = newLocations.filter({ $0 != previousLocation})
//        //print("COUNT \(newLocations.count)")
//        while newLocations.count > 0 {
////            print("PREV\(previousLocation)")
//            if let nextLocation = previousLocation.closestLocation(newLocations) {
////                print("NEXT\(nextLocation)")
//                sortedLocation.append(nextLocation)
//                previousLocation = nextLocation
//                newLocations = newLocations.filter({ $0 != previousLocation})
//
//            }
//        }
////        print("AFTER LOOP \(newLocations.count)")
//        for n in 0...(sortedLocation.count-1) {
////            print("Elm number\(n), point is \(sortedLocation[n])")
//        }
//        return sortedLocation
//    }
//    
//    func calculateDirections(_ toLocation: CLLocationCoordinate2D, transportType: MKDirectionsTransportType, completionHandler: @escaping MKDirectionsHandler) {
//        // this is really just a convenience wrapper for doing MapKit calculation of directions
//        let fromLocationMapItem = MKMapItem(
//            placemark: MKPlacemark(coordinate: self, addressDictionary: nil))
//        let toLocationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: toLocation, addressDictionary: nil))
//        
//        let directionsRequest = MKDirectionsRequest()
//        directionsRequest.transportType = .automobile
//        directionsRequest.source = fromLocationMapItem
//        directionsRequest.destination = toLocationMapItem
//        let directions = MKDirections(request: directionsRequest)
//        directions.calculate { (response, error) in
//            guard let response = response else {
//                //handle the error here
//                completionHandler(nil, error)
//                return
//            }
//            completionHandler(response, nil)
//        }
//    }
//    
//    static func calculateDirections(_ locations: [CLLocationCoordinate2D], transportType: MKDirectionsTransportType, completionHandler: @escaping ([MKRoute]) -> Void) {
//    // one by one, iterate through the locations in the array
//    // calculate their directions and add the route to an array
//    // once you've got all the routes in an array and made it through the whole array, call the completion handler passing in the array of *all* the MKRoutes for every point
//        var routes = [MKRoute]()
//        for n in 0...locations.count-2 {
//            locations[n].calculateDirections(locations[n+1], transportType: .automobile, completionHandler: { (response, error) in
//                guard let response = response else {
//                    return
//                }
//                let route = response.routes[0] 
//                print("GOT ROUTE \(route)")
//                routes.append(route)
//                if routes.count == locations.count-1 {
//                    print("GOT ALL ROUTES")
//                    print("ROUTES \(routes.count)")
//                    completionHandler(routes)
//                }
//            })
//        }
//
//        
//    }
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    if lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude {
        return true
    }
    return false
}

public func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return !(lhs == rhs)
}
