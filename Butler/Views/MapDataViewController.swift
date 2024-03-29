//
//  MapDataViewController.swift
//  Butler
//
//  Created by blackbriar on 9/12/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapDataViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    

    @IBOutlet weak var mapView: MKMapView!
    
    let managedObjectContext = ((UIApplication.shared.delegate) as! AppDelegate).managedObjectContext
    
    var items: [Item]?
    let locationManager = CLLocationManager()
    var points = [CLLocationCoordinate2D]()
    var lastKnowLocation: CLLocation?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x0099E8)]
        
        
        self.mapView.delegate = self
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy =  kCLLocationAccuracyBest
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        updateMonitoredRegions()
//        drawPolyline()
//        generateRoute()
    }
    
    func fetchData() {
//        print("CALLING FETCH DATA IN MAPS")
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        //Q: how to "rerange"
        //        let prioritySort  = NSSortDescriptor(key: "priority", ascending: false)
        do {
            let fetchResults = try managedObjectContext.fetch(fetch) as! [Item]
            items = fetchResults
            addAnnotations()
        } catch {
            fatalError("Failed to fetch category information: \(error)")
        }
    
    }
    
    // Start monitored regions for categories
    func startMonitoringRegions() {
        for item in items! {
            if Bool(item.active!) {
//                print("adding one active region with title \(item.title!)")
                let coordinate = CLLocationCoordinate2D(latitude: Double (item.latitude!), longitude: Double(item.longitude!))
                let region = CLCircularRegion(center: coordinate, radius: Double(item.radius!), identifier: item.title!)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    // Update monitored regions
    func updateMonitoredRegions() {
        self.locationManager.startUpdatingLocation()
        clearMonitoredRegions()
        startMonitoringRegions()
    }
    
    // Clear monitored regions
    func clearMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Notify the user when they have entered a region
        let title = "Hey! Looks like you are close to one of your tasks"
        generateMessage(title, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Notify the user when they leave a region
        let title = "Oh-oh! You appear to be leaving your radius"
        generateMessage(title, region: region)
        
    }
    
    // Generate an alert/notification message when arriving/leaving a region
    func generateMessage(_ title: String, region: CLRegion) {
        if UIApplication.shared.applicationState == .active {
//            print("APP is active")
            // App is active, show an alert
            let alertController = UIAlertController(title: title, message: region.identifier, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
//            print("APP is inactive")
            // App is inactive, show a notification
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.soundName = "customsound.caf"
            notification.alertBody = region.identifier
            // not used for now
            notification.userInfo = ["title" : title]
            notification.category = "Map_Category"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    // Add annotations on map
    func addAnnotations() {
//        print("CALLING ADD ANOTATIONS")
//        print("There are \(items?.count) items")
        // Remove previous annotations before add annotations
        mapView.removeAnnotations(self.mapView.annotations)
        // Remove previous radius circles
        mapView.removeOverlays(self.mapView.overlays)
        
        for item in items! {
            // if the location information is not nil, should NEVER be, but this will prevent compiler from crashing
            if (item.latitude != nil && item.longitude != nil) {
                let coordinate = CLLocationCoordinate2D(latitude: Double(item.latitude!), longitude: Double(item.longitude!))
                points.append(coordinate)
                // add marker for each location
                let mapAnnotation = ItemAnnotation()
                mapAnnotation.buildFromItem(item)
//                print("Ading anotcation marker")
                mapView.addAnnotation(mapAnnotation)
                // add circle for each annotation
                let circle = MKCircle(center: coordinate, radius: Double(item.radius!))
                self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
                mapView.add(circle)
            }
        }
    }
    
    /*
     // MARK: - MapView delegate
     */
 
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // do not pin user location
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let itemAnnotation = annotation as! ItemAnnotation
            pinView?.animatesDrop = true
//            print("IS THIS ITEM ACTIVE \(itemAnnotation.item!.active!)")
            pinView?.pinTintColor = itemAnnotation.pinColor
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "showItem", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(hex: 0x0099E8)
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        // Constructing a circle overlay filled with a blue color
        circleRenderer.fillColor = UIColor(hex: 0x0099E8, alpha: 0.1)
        circleRenderer.strokeColor = UIColor(hex: 0x0099E8)
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Only show user location in MapView if user has authorized location tracking
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        lastKnowLocation = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta:0.02,longitudeDelta:0.02))
        self.mapView.setRegion(region, animated: true)
        //generateRoute()
    }
    
    func drawPolyline() {
        let filteredOverlays = self.mapView.overlays.filter{ $0.isKind(of: MKGeodesicPolyline.self) }
        self.mapView.removeOverlays(filteredOverlays)
        let lastLocation = CLLocationCoordinate2D(latitude: 40.759211, longitude: -73.984638)
        self.points.append(lastLocation)
        let geodesic = MKPolyline(coordinates: &points, count: points.count)
        self.mapView.add(geodesic)
    }
    
    func showRoutes(_ routes: [MKRoute]) {
        for i in 0..<routes.count {
            drawRoute(routes[i])
        }
    }
    
    func drawRoute(_ route: MKRoute) {
        self.mapView.add(route.polyline)//, level: MKOverlayLevel.AboveRoads)
    }
    
//    func generateRoute() {
//        print("CAALING SORT")
//        lastKnowLocation = CLLocation(latitude: 40.759211, longitude: -73.984638)
//        let sortedDirections = lastKnowLocation!.coordinate.locationsSortedByDistanceFromPreviousLocation(self.points)
//        print("SORTED DIRECTIONS COUNT\(sortedDirections.count)")
//        print(sortedDirections)
//        CLLocationCoordinate2D.calculateDirections(sortedDirections, transportType: .walking) { routes in
//            // call method which adds the array of routes to the map
////            self.showRoutes(routes)
//            print("ROUTES are\(routes)")
//            self.mapView.add(routes[1].polyline)
//        }
//    }
    
    

    /*
    // MARK: - Navigation
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            let destinationVC = segue.destination as! AddItemTableViewController
            let selectedAnnotation = self.mapView.selectedAnnotations[0] as! ItemAnnotation
            destinationVC.item = selectedAnnotation.item
        }
    }

}
