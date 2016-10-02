//
//  MapViewController.swift
//  Butler
//
//  Created by blackbriar on 9/5/16.
//  Copyright © 2016 com.teressa. All rights reserved.
//

import UIKit
import MapKit

protocol SetLocationDelegate {
    func setLocation(lastLocation: Location)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var lastLocation: Location?
    var setLocationDelegate: SetLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change navigation button colors to match the overall blue color in the app
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: 0x0099E8)]
        self.navigationController!.navigationBar.tintColor = UIColor(hex: 0x0099E8)
        self.navigationItem.backBarButtonItem?.tintColor = UIColor(hex: 0x0099E8)
        
        self.searchBar.delegate = self
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        self.locationManager.requestAlwaysAuthorization()
        // add longPress gesture to the map
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.didLongPressMap(_:)))
        longPress.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPress)
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (lastLocation != nil) {
            let newCoordinates = CLLocationCoordinate2D(latitude: lastLocation!.latitude, longitude: lastLocation!.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            annotation.title = lastLocation!.name
            self.mapView.addAnnotation(annotation)
            let region = MKCoordinateRegionMake(newCoordinates, MKCoordinateSpanMake(0.02, 0.02))
//            let mapRegion = self.mapView.regionThatFits(region)
//            self.mapView.setRegion(mapRegion, animated: true)
//            let region = MKCoordinateRegion(center: newCoordinates, span: MKCoordinateSpan(latitudeDelta:0.02,longitudeDelta:0.02))
            self.mapView.setRegion(region, animated: true)
            
        }
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
//        print("SEARCH CLICked")
        searchBar.resignFirstResponder()
        if let location = searchBar.text where !location.isEmpty{
            geocoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    // Handle potential errors
                    if (error?.code == 8) {
                        // No result found with geocode request
                        // Show alert to user
                        self.showAlertWithDismiss("No result found", message: "Unable to provide a location for your search request.")
                    } else {
                        // Other error, print to console
                        print(error?.localizedDescription)
                    }
                }
                // Get the first location result and add it to the map
                if let placemark = placemarks?.first {
                    // Remove existing annotations (if any) from map view
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    // Place new annotation and center camera on location
                    let coord = placemark.location?.coordinate
                    let newCenter = CLLocationCoordinate2D(latitude: (coord?.latitude)!, longitude: (coord?.longitude)!)
                    let region = MKCoordinateRegion(center: newCenter, span: MKCoordinateSpan(latitudeDelta:0.01,longitudeDelta:0.01))
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
//                    print("Placemark name is \(placemark.name)")
                    self.lastLocation = Location(name: searchBar.text!, longitude:( coord?.longitude)!, latitude: (coord?.latitude)!)
                }
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     */
    
     @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.showAlertConfirm("Choose this location", message: "Are you sure this is the location?")
     }
    
    // Helper function to produce an alert for the user
    func showAlertWithDismiss(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertDismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(alertDismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showAlertConfirm(title: String, message: String) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = self.view.bounds
        blur.alpha = 1
        blur.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yeah, that's right", style: .Default) { (action:UIAlertAction) in
            if let location = self.lastLocation {
                self.setLocationDelegate?.setLocation(location)
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                UIView.animateWithDuration(0.7, animations: {
                    //  EITHER...
                    //blur.effect = nil
                    blur.alpha = 0
                    }, completion: { (finished: Bool) -> Void in
                        blur.removeFromSuperview()
                } )
                self.showAlertWithDismiss("Location missing", message: "Are you sure you picked a location?")
            }
        }
        let cancelAction = UIAlertAction(title: "No, let me think again", style: .Default) { (action:UIAlertAction) in
            UIView.animateWithDuration(0.7, animations: {
                //  EITHER...
                //blur.effect = nil
                blur.alpha = 0
                }, completion: { (finished: Bool) -> Void in
                    blur.removeFromSuperview()
            } )
        }
        view.addSubview(blur)
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    /* 
    // MARK: - MapViewDelegate
     */
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // do not pin user location
        if annotation is MKUserLocation {
            return nil }
        else {
            let pinView:MKPinAnnotationView = MKPinAnnotationView()
            pinView.annotation = annotation
            pinView.pinTintColor = UIColor.redColor()
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            return pinView
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.showAlertConfirm("Choose this location", message: "Are you sure this is the location?")
    }

    func didLongPressMap(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            self.mapView.removeAnnotations(self.mapView.annotations)
            let touchPoint = sender.locationInView(self.mapView)
            let touchCoordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
//            print("Lat: \(touchCoordinate.latitude) and Long: \(touchCoordinate.longitude)")
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    annotation.title = pm.name
//                    print("NAME IS\(pm.name)")
                    self.lastLocation = Location(name: annotation.title!, longitude: touchCoordinate.longitude, latitude: touchCoordinate.latitude)
                }
                else {
                    annotation.title = "Unknown Place"
//                    print("Problem with the data received from geocoder")
                    self.lastLocation = Location(name: annotation.title!, longitude: touchCoordinate.longitude, latitude: touchCoordinate.latitude)
                }
            })
//            print("TITLE is \(annotation.title)")
            self.mapView.addAnnotation(annotation)
            let region = MKCoordinateRegionMake(touchCoordinate, MKCoordinateSpanMake(0.02, 0.02))
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    /* 
    // MARK: - CLLocationManagerDelegate
     */
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta:0.02,longitudeDelta:0.02))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
}
