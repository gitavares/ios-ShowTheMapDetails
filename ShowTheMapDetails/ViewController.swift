//
//  ViewController.swift
//  ShowTheMapDetails
//
//  Created by Giselle Tavares on 2019-03-25.
//  Copyright © 2019 Giselle Tavares. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var theMap: MKMapView!
    
    var pin1: MKPointAnnotation?
    var pin2: MKPointAnnotation?
    
    var timer = Timer()
    
    var addressA = ""
    var addressB = ""
    var distance = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theMap.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        theMap.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let overlays = theMap.overlays
        theMap.removeOverlays(overlays)
        
        let allAnnotations = self.theMap.annotations
        self.theMap.removeAnnotations(allAnnotations)
        
        pin1 = nil
        pin2 = nil
    }
    
    @objc func mapTapped(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: theMap)
        let coordinates = theMap.convert(touchPoint, toCoordinateFrom: theMap)
        
        if let pin1 = pin1 {
            if let _ = pin2 {
                
            } else {
                pin2 = MKPointAnnotation()
                pin2?.coordinate = coordinates
                getAddress(from: coordinates) { address in
                    if let address = address {
                        self.pin2?.title = "B"
                        self.theMap.addAnnotation(self.pin2!)
                        self.addressB = address
                        print(self.addressB)
                    } else {
                        self.pin2?.title = "B"
                        self.theMap.addAnnotation(self.pin2!)
                    }
                    let routeLine = MKPolyline(coordinates: [pin1.coordinate, self.pin2!.coordinate], count: 2)
                    self.theMap.addOverlay(routeLine)
                    
                    let location1 = CLLocation(latitude: pin1.coordinate.latitude, longitude: pin1.coordinate.longitude)
                    let location2 = CLLocation(latitude: self.pin2!.coordinate.latitude, longitude: self.pin2!.coordinate.longitude)
                    let distance = location1.distance(from: location2) / 1000
                    self.distance = "\(String(format: "%.2f", distance)) km"
                    print(self.distance)
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(ViewController.goToDetails)), userInfo: nil, repeats: false)
                    
                }
            }
        } else {
            pin1 = MKPointAnnotation()
            pin1?.coordinate = coordinates
            getAddress(from: coordinates) { address in
                if let address = address {
                    self.pin1?.title = "A"
                    self.theMap.addAnnotation(self.pin1!)
                    self.addressA = address
                    print(self.addressA)
                } else {
                    self.pin1?.title = "A"
                    self.theMap.addAnnotation(self.pin1!)
                }
            }
        }
    }
    
    @objc func goToDetails(){
        self.performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MapDetailsViewController
        
        destinationVC.addressA = addressA
        destinationVC.addressB = addressB
        destinationVC.distance = distance
    }
    
    func getAddress(from coordinates: CLLocationCoordinate2D, completion: @escaping (String?) -> ()) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            // Country
            guard let country = placeMark.country else {
                completion(nil)
                return
            }
            guard let city = placeMark.subAdministrativeArea else {
                completion(country)
                return
            }
            guard let street = placeMark.thoroughfare else {
                completion("\(city), \(country)")
                return
            }
            completion("\(street), \(city), \(country)")
        })
    }
    
    func findMidpoint(between coordinate1: CLLocationCoordinate2D, and coordinate2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        var midpoint = CLLocationCoordinate2D()
        let lon1 = coordinate1.longitude * .pi / 180
        let lon2 = coordinate2.longitude * .pi / 180
        
        let lat1 = coordinate1.latitude * .pi / 180
        let lat2 = coordinate2.latitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        midpoint.latitude  = lat3 * 180 / .pi
        midpoint.longitude = lon3 * 180 / .pi
        
        return midpoint
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            polylineRender.lineWidth = 2
            return polylineRender
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
            
        } else {
            
            if let _ = Double(String(annotation.title!!.split(separator: " ")[0])) {
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "some")
                let annotationLabel = UILabel(frame: CGRect(x: -52, y: 5, width: 105, height: 30))
                annotationLabel.numberOfLines = 0
                annotationLabel.textAlignment = .center
                annotationLabel.font = UIFont(name: "Rockwell", size: 10)
                annotationLabel.text = annotation.title!
                annotationView.image = nil
                annotationView.addSubview(annotationLabel)
                return annotationView
            } else {
                return nil
            }
            
        }
    }

}

